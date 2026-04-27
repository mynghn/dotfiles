#!/usr/bin/env python3
"""Validate LeanPlan feature artifacts.

Usage:
  python3 validate.py docs/features/KEY [--stage full] [--json] [--allow-large]
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path


SURFACE_FILES = {
    "requirement": "requirement.md",
    "spec": "spec.md",
    "design": "design.md",
    "plan": "plan.md",
}

OPTIONAL_FILES = {
    "rationale": "design-rationale.md",
    "research": "research.md",
}

STAGE_ORDER = ("requirement", "spec", "design", "plan")

HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$", re.MULTILINE)
ANCHOR_RE = re.compile(r"^(#{2,4})\s+((O|INV|Decision)-(\d+):\s+([a-z0-9][a-z0-9-]*))\s*$", re.MULTILINE)
TASK_RE = re.compile(r"^(#{2,4})\s+Task:\s+([A-Za-z][A-Za-z0-9-]*)\s*$", re.MULTILINE)
CITATION_RE = re.compile(
    r"\b(?P<file>SPEC|DESIGN|RATIONALE|RESEARCH|TASK)#(?P<target>"
    r"(?:O|INV|Decision)-\d+-[a-z0-9][a-z0-9-]*|Task:[A-Za-z][A-Za-z0-9-]*)"
)
# A SPEC O/INV item appearing on a line containing **GAP** is treated as
# deliberately uncovered — see references/artifact-contract.md "**GAP**
# acknowledgment". Validator skips it in forward-coverage checks.
GAP_RE = re.compile(r"\*\*GAP\*\*")
FRONTMATTER_RE = re.compile(r"^---\s*\n.*?\n---\s*\n", re.DOTALL)
CODE_FENCE_RE = re.compile(r"```(?P<lang>[A-Za-z0-9_-]*)\n(?P<body>.*?)```", re.DOTALL)
SCRIPTY_TASK_RE = re.compile(
    r"\b(edit|modify|change|replace)\s+(?:file\s+)?[`'\"]?[^`\n'\"]+[`'\"]?\s+"
    r"(?:at|on)\s+(?:line|L)\s*\d+",
    re.IGNORECASE,
)


@dataclass
class Issue:
    level: str
    path: str
    message: str
    line: int | None = None


class Validator:
    def __init__(self, feature_dir: Path, stage: str, allow_large: bool, strict: bool = False) -> None:
        self.feature_dir = feature_dir
        self.stage = stage
        self.allow_large = allow_large
        self.strict = strict
        self.issues: list[Issue] = []
        self.texts: dict[str, str] = {}

    def run(self) -> list[Issue]:
        self._load_files()
        self._check_required_files()
        self._check_common()

        if self._includes("requirement"):
            self._check_requirement()
        if self._includes("spec"):
            self._check_spec()
        if self._includes("design"):
            self._check_design()
        if self._includes("plan"):
            self._check_plan()
            self._check_traceability()
        return self.issues

    def _includes(self, stage: str) -> bool:
        if self.stage == "full":
            return True
        return STAGE_ORDER.index(stage) <= STAGE_ORDER.index(self.stage)

    def _load_files(self) -> None:
        for key, filename in {**SURFACE_FILES, **OPTIONAL_FILES}.items():
            path = self.feature_dir / filename
            if path.exists():
                self.texts[key] = path.read_text(encoding="utf-8")

    def _check_required_files(self) -> None:
        if not self.feature_dir.exists():
            self._error(".", f"feature directory does not exist: {self.feature_dir}")
            return
        for stage in STAGE_ORDER:
            if self._includes(stage) and stage not in self.texts:
                self._error(SURFACE_FILES[stage], "required surface artifact is missing")

    def _check_common(self) -> None:
        for key, text in self.texts.items():
            filename = self._filename_for_key(key)
            if FRONTMATTER_RE.match(text):
                self._warn(filename, "frontmatter is discouraged; artifact type is implied by filename", 1)
            self._check_duplicate_anchors(filename, text)
            self._check_citations(filename, text)
            self._check_must_usage(filename, text)

    def _check_requirement(self) -> None:
        text = self.texts.get("requirement", "")
        if not text:
            return
        self._require_sections("requirement.md", text, ("Problem", "Outcome"))
        self._warn_empty_conditional("requirement.md", text, ("Non-goals", "Upstream"))
        banned = ("Kafka", "Redis", "Spring", "Kotlin", "Postgres", "MySQL", "gRPC", "Flink")
        for term in banned:
            if re.search(rf"\b{re.escape(term)}\b", text):
                self._warn("requirement.md", f"possible implementation choice in REQUIREMENT: {term}")

    def _check_spec(self) -> None:
        text = self.texts.get("spec", "")
        if not text:
            return
        self._require_sections("spec.md", text, ("Outcome",))
        outcomes = self._anchors("spec", kind="O")
        if not outcomes:
            self._error("spec.md", "SPEC Outcome must contain at least one O anchor")
        if self._has_section(text, "Invariants") and not self._anchors("spec", kind="INV"):
            self._error("spec.md", "Invariants section exists but has no INV anchors")
        self._warn_empty_conditional("spec.md", text, ("Invariants", "Non-goals"))
        if re.search(r"^\s*-\s+\[[ xX]\]", text, re.MULTILINE):
            self._warn("spec.md", "checkbox acceptance criteria are not LeanPlan anchors")

    def _check_design(self) -> None:
        text = self.texts.get("design", "")
        if not text:
            return
        self._require_sections("design.md", text, ("Architecture",))
        if "```mermaid" not in text:
            self._error("design.md", "Architecture must include a Mermaid diagram")
        if not self._anchors("design", kind="Decision"):
            self._error("design.md", "DESIGN must contain at least one Decision anchor")
        self._check_design_rationale_consistency()

    def _check_plan(self) -> None:
        text = self.texts.get("plan", "")
        if not text:
            return
        # plan.md may use either "Dependency DAG" or just "DAG" as the section header.
        if self._has_section(text, "Dependency DAG"):
            dag_section = "Dependency DAG"
        elif self._has_section(text, "DAG"):
            dag_section = "DAG"
        else:
            self._error("plan.md", "missing required section: Dependency DAG (or DAG)")
            dag_section = None
        if dag_section and "```mermaid" not in self._section_body(text, dag_section):
            self._error("plan.md", f"{dag_section} must be Mermaid")
        self._warn_ascii_diagram("plan.md", text)
        tasks = self._tasks()
        if not tasks:
            self._error("plan.md", "TASK artifact must contain at least one task card")
        # One-deployment guardrail: advisory by default; --strict escalates to error;
        # --allow-large overrides entirely.
        if not self.allow_large:
            if len(tasks) > 16:
                msg = f"task count {len(tasks)} exceeds one-deployment guardrail (>16)"
                if self.strict:
                    self._error("plan.md", msg)
                else:
                    self._warn("plan.md", msg)
            elif len(tasks) > 12:
                self._warn("plan.md", f"task count {len(tasks)} is near the one-deployment limit (>12)")
        if re.search(r"^\s*-\s+\[[ xX]\]", text, re.MULTILINE):
            self._warn("plan.md", "checkbox task lists are discouraged; use task cards")
        for task_id, body, line in tasks:
            if SCRIPTY_TASK_RE.search(body):
                self._warn("plan.md", f"Task {task_id} looks like line-level scripting", line)
            if not self._task_has_reason(body):
                self._error("plan.md", f"Task {task_id} has no SPEC/DESIGN/guideline reason citation", line)

    def _check_traceability(self) -> None:
        if "spec" not in self.texts or "plan" not in self.texts:
            return
        plan_text = self.texts.get("plan", "")
        # Collect SPEC item IDs annotated as **GAP** in plan.md (deliberately uncovered).
        gap_acked = self._gap_acknowledged_targets(plan_text)
        for anchor in self._anchors("spec", kind="O") + self._anchors("spec", kind="INV"):
            target = anchor["target"]
            if f"SPEC#{target}" in plan_text:
                continue
            if target in gap_acked:
                continue
            self._error("plan.md", f"SPEC anchor is not covered by any task: SPEC#{target}")

    def _gap_acknowledged_targets(self, plan_text: str) -> set[str]:
        """Return SPEC item targets (e.g. 'O-1-foo' or 'INV-3-bar') annotated on a
        line containing **GAP**. Lines may reference the item by full target
        (O-1-foo / INV-3-bar) or by ID alone (O-1 / INV-3); both forms are
        accepted as ack."""
        acked: set[str] = set()
        # Map ID-only to full targets we know about so a bare 'INV-3' on a GAP
        # line ack's INV-3-<whatever-slug>.
        spec_targets = {a["target"] for a in self._anchors("spec", kind="O")} | {
            a["target"] for a in self._anchors("spec", kind="INV")
        }
        id_to_targets: dict[str, list[str]] = {}
        for t in spec_targets:
            # target form: 'O-1-foo-bar' or 'INV-3-baz'; extract 'O-1' / 'INV-3'.
            m = re.match(r"((?:O|INV)-\d+)-", t)
            if m:
                id_to_targets.setdefault(m.group(1), []).append(t)
        for line in plan_text.splitlines():
            if not GAP_RE.search(line):
                continue
            # Full-target form on the GAP line.
            for m in re.finditer(r"\b((?:O|INV)-\d+-[a-z0-9][a-z0-9-]*)\b", line):
                acked.add(m.group(1))
            # ID-only form on the GAP line — ack all matching targets.
            for m in re.finditer(r"\b((?:O|INV)-\d+)\b", line):
                for t in id_to_targets.get(m.group(1), []):
                    acked.add(t)
        return acked

    def _check_duplicate_anchors(self, filename: str, text: str) -> None:
        seen: dict[str, int] = {}
        for item in self._parse_anchors(text):
            target = item["target"]
            if target in seen:
                self._error(filename, f"duplicate anchor: {target}", item["line"])
            seen[target] = item["line"]
        seen_tasks: dict[str, int] = {}
        for task in self._parse_tasks(text):
            target = f"Task:{task['id']}"
            if target in seen_tasks:
                self._error(filename, f"duplicate task anchor: {target}", task["line"])
            seen_tasks[target] = task["line"]

    def _check_citations(self, filename: str, text: str) -> None:
        anchors_by_file = {
            "SPEC": {a["target"] for a in self._anchors("spec")},
            "DESIGN": {a["target"] for a in self._anchors("design")},
            "RATIONALE": {a["target"] for a in self._anchors("rationale")},
            "TASK": {f"Task:{t['id']}" for t in self._parse_tasks(self.texts.get("plan", ""))},
        }
        for match in CITATION_RE.finditer(text):
            file_key = match.group("file")
            target = match.group("target")
            if file_key == "RESEARCH":
                continue
            if target not in anchors_by_file.get(file_key, set()):
                self._error(filename, f"broken citation: {file_key}#{target}", self._line_for_offset(text, match.start()))

    def _check_must_usage(self, filename: str, text: str) -> None:
        if filename == "spec.md":
            return
        for match in re.finditer(r"\bMUST(?:\s+NOT)?\b", text):
            self._warn(filename, "MUST/MUST NOT should be reserved for true invariants", self._line_for_offset(text, match.start()))

    def _check_design_rationale_consistency(self) -> None:
        design_anchors = {a["target"] for a in self._anchors("design", kind="Decision")}
        rationale_anchors = {a["target"] for a in self._anchors("rationale", kind="Decision")}
        if "rationale" not in self.texts:
            return
        for target in rationale_anchors - design_anchors:
            self._error("design-rationale.md", f"rationale decision has no matching DESIGN decision: {target}")
        for target in design_anchors:
            if f"design-rationale.md#{target}" in self.texts.get("design", "") and target not in rationale_anchors:
                self._error("design-rationale.md", f"DESIGN links to missing rationale block: {target}")

    def _task_has_reason(self, body: str) -> bool:
        if re.search(r"\b(SPEC#(?:AC|INV)-\d+-[a-z0-9-]+|DESIGN#Decision-\d+-[a-z0-9-]+)", body):
            return True
        return bool(re.search(r"\*\*Guidelines\*\*:\s*\S|^## Guidelines\b", body, re.MULTILINE))

    def _warn_ascii_diagram(self, filename: str, text: str) -> None:
        for fence in CODE_FENCE_RE.finditer(text):
            lang = fence.group("lang").strip().lower()
            body = fence.group("body")
            if lang == "" and ("┌" in body or "-->" in body or "->" in body):
                self._warn(filename, "ASCII diagram/code-fence detected; use Mermaid", self._line_for_offset(text, fence.start()))
        if re.search(r"^\s*#{2,4}\s+ASCII DAG\b", text, re.MULTILINE):
            self._warn(filename, "ASCII DAG section detected; use Mermaid only")

    def _require_sections(self, filename: str, text: str, sections: tuple[str, ...]) -> None:
        for section in sections:
            if not self._has_section(text, section):
                self._error(filename, f"missing required section: {section}")

    def _warn_empty_conditional(self, filename: str, text: str, sections: tuple[str, ...]) -> None:
        for section in sections:
            if self._has_section(text, section) and not self._section_body(text, section).strip():
                self._warn(filename, f"conditional section is empty: {section}")

    def _has_section(self, text: str, section: str) -> bool:
        return bool(re.search(rf"^##\s+{re.escape(section)}\s*$", text, re.MULTILINE))

    def _section_body(self, text: str, section: str) -> str:
        match = re.search(rf"^##\s+{re.escape(section)}\s*$", text, re.MULTILINE)
        if not match:
            return ""
        next_match = re.search(r"^##\s+", text[match.end() :], re.MULTILINE)
        end = match.end() + next_match.start() if next_match else len(text)
        return text[match.end() : end]

    def _anchors(self, key: str, kind: str | None = None) -> list[dict[str, object]]:
        return [
            a
            for a in self._parse_anchors(self.texts.get(key, ""))
            if kind is None or a["kind"] == kind
        ]

    def _tasks(self) -> list[tuple[str, str, int]]:
        text = self.texts.get("plan", "")
        parsed = self._parse_tasks(text)
        result = []
        for index, task in enumerate(parsed):
            start = int(task["end"])
            end = int(parsed[index + 1]["start"]) if index + 1 < len(parsed) else len(text)
            result.append((str(task["id"]), text[start:end], int(task["line"])))
        return result

    def _parse_anchors(self, text: str) -> list[dict[str, object]]:
        anchors = []
        for match in ANCHOR_RE.finditer(text):
            kind = match.group(3)
            number = match.group(4)
            slug = match.group(5)
            anchors.append({
                "kind": kind,
                "target": f"{kind}-{number}-{slug}",
                "line": self._line_for_offset(text, match.start()),
            })
        return anchors

    def _parse_tasks(self, text: str) -> list[dict[str, object]]:
        tasks = []
        for match in TASK_RE.finditer(text):
            tasks.append({
                "id": match.group(2),
                "start": match.start(),
                "end": match.end(),
                "line": self._line_for_offset(text, match.start()),
            })
        return tasks

    def _filename_for_key(self, key: str) -> str:
        if key in SURFACE_FILES:
            return SURFACE_FILES[key]
        return OPTIONAL_FILES[key]

    def _line_for_offset(self, text: str, offset: int) -> int:
        return text.count("\n", 0, offset) + 1

    def _error(self, path: str, message: str, line: int | None = None) -> None:
        self.issues.append(Issue("error", path, message, line))

    def _warn(self, path: str, message: str, line: int | None = None) -> None:
        self.issues.append(Issue("warning", path, message, line))


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate LeanPlan feature artifacts")
    parser.add_argument("feature_dir", type=Path)
    parser.add_argument(
        "--stage",
        choices=("requirement", "spec", "design", "plan", "full"),
        default="full",
        help="Validate through the selected stage",
    )
    parser.add_argument("--json", action="store_true", help="Emit JSON")
    parser.add_argument("--allow-large", action="store_true", help="Allow more than 16 tasks")
    parser.add_argument(
        "--strict",
        action="store_true",
        help=(
            "Strict mode: escalate the one-deployment guardrail breach (>16 tasks) to an error, "
            "and exit non-zero if any warnings are present. Honors $LEANPLAN_STRICT=1 as well."
        ),
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    strict = args.strict or os.environ.get("LEANPLAN_STRICT") == "1"
    issues = Validator(args.feature_dir, args.stage, args.allow_large, strict).run()
    if args.json:
        print(json.dumps([asdict(issue) for issue in issues], ensure_ascii=False, indent=2))
    else:
        if not issues:
            print("LeanPlan validation passed.")
        else:
            for issue in issues:
                loc = issue.path if issue.line is None else f"{issue.path}:{issue.line}"
                print(f"{issue.level.upper()}: {loc}: {issue.message}")
    has_error = any(issue.level == "error" for issue in issues)
    has_warning = any(issue.level == "warning" for issue in issues)
    if has_error:
        return 1
    if strict and has_warning:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
