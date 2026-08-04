#!/usr/bin/env python3
"""L1/L2 deterministic checks for the software-digest skill and its produced digests.

Hardness L1/L2 only: every check here is an assertion or a rule applied to text — no
judgment, no model. Semantic quality is the L4 judge's job (see rubric.md).

Usage:  check.py <repo-root> <cache-dir> [scenario-id ...]
        (no scenario ids = all scenarios)
"""
import os
import re
import sys

SKILL_DIR = "dot_agents/skills/software-digest"
SYMLINK = "dot_claude/skills/symlink_software-digest"
SYMLINK_TARGET = "../../.agents/skills/software-digest"

# scenario id -> (fixture subdir under cache, human label)
SCENARIOS = {
    "s1-bubbletea-pr": ("bubbletea", "change delta: bubbletea PR #1691"),
    "s2-chezmoi-repo": ("chezmoi", "whole system: chezmoi dotfiles @1de81ed"),
    "s3-starlette": ("starlette", "unfamiliar project: starlette 1.3.1"),
}

ALLOWED_BASIS = {"verified", "stated", "inferred"}

results = []


def check(scope, name, ok, detail=""):
    results.append((scope, name, bool(ok), detail))


def text_of(html):
    """Strip tags and collapse whitespace."""
    t = re.sub(r"<script.*?</script>", " ", html, flags=re.S | re.I)
    t = re.sub(r"<style.*?</style>", " ", t, flags=re.S | re.I)
    t = re.sub(r"<[^>]+>", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def section_by_class(html, cls):
    """Return inner HTML of the first element carrying class `cls`, else None."""
    m = re.search(
        r'<(\w+)[^>]*class="[^"]*\b' + re.escape(cls) + r'\b[^"]*"[^>]*>(.*?)</\1>',
        html,
        flags=re.S | re.I,
    )
    return m.group(2) if m else None


# --------------------------------------------------------------- skill package
def check_skill(root):
    scope = "skill"
    path = os.path.join(root, SKILL_DIR, "SKILL.md")
    if not os.path.isfile(path):
        check(scope, "skill-md-exists", False, path)
        return
    check(scope, "skill-md-exists", True)
    raw = open(path, encoding="utf-8").read()

    fm = re.match(r"^---\n(.*?)\n---\n(.*)$", raw, flags=re.S)
    check(scope, "frontmatter-parses", bool(fm))
    if not fm:
        return
    front, body = fm.group(1), fm.group(2)

    name = re.search(r"^name:\s*(\S+)\s*$", front, flags=re.M)
    check(scope, "name-matches-dir", bool(name) and name.group(1) == "software-digest",
          name.group(1) if name else "missing")

    desc = re.search(r'^description:\s*"(.*?)"\s*$', front, flags=re.M | re.S)
    check(scope, "description-present", bool(desc))
    if desc:
        d = desc.group(1)
        check(scope, "description-length", len(d) <= 1024, f"{len(d)} chars (limit 1024)")
        low = d.lower()
        check(scope, "description-no-reserved-words",
              "anthropic" not in low and "claude" not in low)
        check(scope, "description-third-person",
              not re.search(r"\b(I can|I will|you can use this)\b", d, flags=re.I))

    check(scope, "body-under-500-lines", len(body.splitlines()) <= 500,
          f"{len(body.splitlines())} lines")

    refs = set(re.findall(r"references/([A-Za-z0-9._-]+\.md)", raw))
    check(scope, "references-mentioned", len(refs) > 0, f"{len(refs)} referenced")
    missing = [r for r in sorted(refs)
               if not os.path.isfile(os.path.join(root, SKILL_DIR, "references", r))]
    check(scope, "references-exist", not missing, "missing: " + ", ".join(missing))

    # every bundled reference is reachable one level from SKILL.md
    refdir = os.path.join(root, SKILL_DIR, "references")
    on_disk = {f for f in os.listdir(refdir)} if os.path.isdir(refdir) else set()
    orphans = sorted(on_disk - refs)
    check(scope, "no-orphan-references", not orphans, "unlinked: " + ", ".join(orphans))

    sym = os.path.join(root, SYMLINK)
    content = open(sym, encoding="utf-8").read().strip() if os.path.isfile(sym) else ""
    check(scope, "vendor-symlink", content == SYMLINK_TARGET, content or "missing")


# -------------------------------------------------------------------- a digest
def check_digest(scope, html_path, fixture_root, log_path):
    html = open(html_path, encoding="utf-8").read()

    # complete standalone document
    checks = {
        "doctype": r"<!doctype\s+html",
        "html-lang": r"<html[^>]*\blang=",
        "head": r"<head[\s>]",
        "title": r"<title>\s*\S",
        "body": r"<body[\s>]",
    }
    missing = [k for k, pat in checks.items() if not re.search(pat, html, flags=re.I)]
    check(scope, "complete-document", not missing, "missing: " + ", ".join(missing))

    # self-contained: nothing loads over the network
    external = []
    for m in re.finditer(r"<(link|script|img|iframe|source)\b[^>]*>", html, flags=re.I):
        tag = m.group(0)
        if re.search(r'(href|src)\s*=\s*["\']?(https?:)?//', tag, flags=re.I):
            external.append(tag[:80])
    for m in re.finditer(r"<style.*?</style>", html, flags=re.S | re.I):
        if re.search(r"@import|url\(\s*['\"]?(https?:)?//", m.group(0), flags=re.I):
            external.append("<style> remote url()")
    check(scope, "self-contained", not external, "; ".join(external[:3]))

    # inline figure, labelled
    svgs = re.findall(r"<svg\b[^>]*>", html, flags=re.I)
    labelled = [s for s in svgs
                if re.search(r'role\s*=\s*"img"', s, flags=re.I)
                and re.search(r"aria-label\s*=", s, flags=re.I)]
    check(scope, "inline-svg-present", len(svgs) >= 1, f"{len(svgs)} svg")
    check(scope, "svg-accessible", len(svgs) >= 1 and len(labelled) == len(svgs),
          f"{len(labelled)}/{len(svgs)} carry role+aria-label")

    # reader contract
    rc = section_by_class(html, "reader-contract")
    rc_text = text_of(rc) if rc else ""
    check(scope, "reader-contract", bool(rc) and len(rc_text) >= 120,
          f"{len(rc_text)} chars")

    # self-check questions
    sc = section_by_class(html, "self-check")
    sc_text = text_of(sc) if sc else ""
    qs = sc_text.count("?") if sc else 0
    check(scope, "self-check-questions", bool(sc) and qs >= 3, f"{qs} questions")

    # code anchors present and resolving against the pinned fixture
    anchors = re.findall(
        r'<[^>]*class="[^"]*\banchor\b[^"]*"[^>]*data-path="([^"]+)"[^>]*data-line="(\d+)"',
        html, flags=re.I)
    anchors += re.findall(
        r'<[^>]*data-path="([^"]+)"[^>]*data-line="(\d+)"[^>]*class="[^"]*\banchor\b',
        html, flags=re.I)
    seen, uniq = set(), []
    for p, l in anchors:
        if (p, l) not in seen:
            seen.add((p, l))
            uniq.append((p, l))
    check(scope, "anchors-present", len(uniq) >= 3, f"{len(uniq)} anchors")

    bad = []
    for p, line in uniq:
        fp = os.path.join(fixture_root, p)
        if not os.path.isfile(fp):
            bad.append(f"{p}:{line} (no such file)")
            continue
        try:
            with open(fp, "rb") as fh:
                n = sum(1 for _ in fh)
        except OSError as e:
            bad.append(f"{p}:{line} ({e})")
            continue
        if not 1 <= int(line) <= n:
            bad.append(f"{p}:{line} (file has {n} lines)")
    check(scope, "anchors-resolve", not bad,
          f"{len(bad)}/{len(uniq)} unresolved: " + "; ".join(bad[:3]))

    # epistemic basis markers
    bases = re.findall(r'data-basis="([^"]*)"', html, flags=re.I)
    check(scope, "basis-markers-present", len(bases) >= 1, f"{len(bases)} markers")
    invalid = sorted({b for b in bases if b not in ALLOWED_BASIS})
    check(scope, "basis-values-valid", not invalid, "invalid: " + ", ".join(invalid))
    stated = re.findall(r"<[^>]*data-basis=\"stated\"[^>]*>", html, flags=re.I)
    unsourced = [t for t in stated if "data-source=" not in t.lower()]
    check(scope, "stated-claims-sourced", not unsourced,
          f"{len(unsourced)} stated claims without data-source")

    # the gate ran before the digest was written
    if not os.path.isfile(log_path):
        check(scope, "session-log", False, "missing session-log.md")
        check(scope, "gate-before-generation", False, "no log")
    else:
        log = open(log_path, encoding="utf-8").read()
        check(scope, "session-log", True)
        g, d = log.find("## GATE"), log.find("## DIGEST WRITTEN")
        check(scope, "gate-before-generation", g != -1 and d != -1 and g < d,
              f"gate@{g} digest@{d}")


def main():
    root, cache = sys.argv[1], sys.argv[2]
    wanted = sys.argv[3:] or list(SCENARIOS)

    check_skill(root)

    evals = os.path.join(root, "docs/features/0003-software-digest-skill/evals")
    for sid in wanted:
        fixture_sub, label = SCENARIOS[sid]
        fixture_root = os.path.join(cache, fixture_sub)
        work = os.path.join(evals, "work", sid)
        digests = sorted(f for f in os.listdir(work)
                         if f.endswith(".html")) if os.path.isdir(work) else []
        if not os.path.isdir(fixture_root):
            check(sid, "fixture-materialized", False, fixture_root)
            continue
        check(sid, "fixture-materialized", True)
        if not digests:
            check(sid, "digest-exists", False, f"no .html in {work}")
            continue
        check(sid, "digest-exists", True, digests[0])
        check_digest(sid, os.path.join(work, digests[0]), fixture_root,
                     os.path.join(work, "session-log.md"))

    width = max(len(f"[{s}] {n}") for s, n, _, _ in results) + 2
    print("=== software-digest — L1/L2 deterministic checks ===\n")
    scope = None
    for s, n, ok, detail in results:
        if s != scope:
            scope = s
            print(f"-- {s} {'— ' + SCENARIOS[s][1] if s in SCENARIOS else ''}")
        label = f"[{s}] {n}"
        tail = f"   {detail}" if detail and not ok else ""
        print(f"  {label.ljust(width, '.')} {'PASS' if ok else 'FAIL'}{tail}")
    npass = sum(1 for *_, ok, _ in ((r[0], r[1], r[2], r[3]) for r in results) if ok)
    nfail = len(results) - npass
    print(f"\n--- SUMMARY: {npass} PASS, {nfail} FAIL ---")
    print(f"RESULT: {'PASS' if nfail == 0 else 'FAIL'}")
    return 1 if nfail else 0


if __name__ == "__main__":
    sys.exit(main())
