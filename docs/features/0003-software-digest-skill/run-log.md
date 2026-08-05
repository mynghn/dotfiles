# Convergence log

Running record of what each matrix run found. `evals/` is frozen at `9641e5e`; this file lives
outside it. Terminology: **matrix** = `run.sh` (L1/L2, all scenarios) + one fresh isolated L4 judge
per scenario. Two consecutive matrices must pass on the *same* skill state.

## Matrix 0 — skill @`9641e5e` (superseded)

L1/L2 **57 PASS / 0 FAIL**. Judges: s1 **9/9**, s2 **9/9**, s3 **8/9 FAIL**.

Two defect classes, both in the same hole — the verify pass covered located positive claims only:

1. **Quantities ungrounded** (s1 and s2, non-blocking evidence lines). Per-file diff counts off by 2
   (`cursed_renderer.go` +10−4 claimed vs +8−2 real); payload line counts off by one. Anchors ground
   *where* a claim comes from; nothing grounded *how many*. → fixed in `4a58e88`.
2. **Absence claims unverified** (s3, item `basis-honest` FAILED). The ledger sent the reader to
   anyio for the threadpool limit while the fixture's own `docs/threadpool.md:18-30` gave the default,
   the caveat and the adjustment recipe. The absence was inferred from where the answer was expected
   to live, never searched for. → fixed in `02cf149`.

The frozen harness got no new machine check for either: the freeze holds, and the judges had already
demonstrated they catch both.

## Matrix 1 — skill @`02cf149`

L1/L2 **57 PASS / 0 FAIL** (regenerated digests).

Both fixes show up in runner behaviour before the judges even weigh in: s1 reports quantities
"recomputed from the fixture, not carried from the PR text"; s2 annotates its ledger entries
"(searched)"; s3 now states the 40-slot threadpool limit as a `stated` doc claim instead of declaring
it absent. s1's runner went further and reverted the fix in place to confirm the regression test
fails without it and passes with it.

- **s1 — PASS (9/9).** Judge independently re-derived every quantity (38 `t.Parallel()` + 1 new = 39;
  7 test files, 6 touched) and re-ran the race reproduction. One cosmetic blemish: the self-check
  lead-in says "세 문제" above four questions.
- **s2 — PASS (9/9).** Judge verified by execution: it fed the figure's depicted input to the real
  merge script and got the figure's exact output order, and re-derived the 1,988/12-slack budget.
  Every absence claim held under its own grep.
- **s3 — FAIL (7/9).** Two items, one theme.
  - `basis-honest`: "저장소 전체에서 uvicorn은 문서의 설치 안내 문구로만 등장한다" is false —
    `docs/middleware.md:114,122` call `uvicorn.run(...)`, `endpoints.md:91` and `schemas.md:94`
    import it, `middleware.md:534,859` cite its ProxyHeadersMiddleware. Also a `stated` claim cites a
    doc section that says the opposite. Every quantity checked out this time.
  - `anchors-say-what-is-claimed`: `gzip.py:44-46` is `IdentityResponder.__call__`, badged `verified`
    as `GZipMiddleware`. The line exists; the symbol is different — and the misattribution then
    contradicted the digest's own rule about per-request instance state.

  → generalized in the next commit. The previous fix caught bare absence ("not in this repository") but not its scoped cousin
  ("appears only as…", "the only place that…"), and the anchor rule checked the line without
  confirming the symbol enclosing it. Both are the same failure: **a claim asserted over a wider span
  than the one actually checked.**

## Matrix 2 — skill @`358734c`

Digests regenerated. The span rule shows up in the drafting itself: s3's runner reports that its
verification pass caught, in its own draft, three defects of exactly the classes that failed matrix 1
— an anchor on line 1 of a 0-byte `py.typed`; two whole-source negatives ("the repo doesn't warn
about background-task durability", "…doesn't mention request-ID middleware") both false against
`docs/background.md:2-5,76-78` and `docs/middleware.md:868-870`; and three anchors sitting on
`@property` decorator lines or an off-by-one signature line, moved onto the symbols they claimed. Its
words: both negatives "were found only because the skill requires searching before writing an edge."

L1/L2 **57 PASS / 0 FAIL**. Judges: s1 **8/9 FAIL**, s2 **9/9**, s3 **9/9**.

- **s3 — PASS (9/9).** The fixture that failed the previous two matrices. The judge verified the
  whole-source quantifications by grep (`starlette.exception_handlers` written once, read once;
  `wrap_app_handling_exceptions` called at exactly three sites) and checked 30+ anchors against their
  enclosing symbols. The span rule did its job where it was aimed.
- **s2 — PASS (9/9).** Quantities re-derived to the byte (OWNED = 600/450/411/293/234 = 1,988, slack
  12); universals held under search.
- **s1 — FAIL (8/9), `basis-honest`.** "이 필드를 읽는 세 곳 (start, flush, onMouse)", badged
  `verified` — `close()` reads it too at `cursed_renderer.go:151`, so there are four. The span rule
  listed negative triggers and missed the positive form: an enumeration asserts completeness with no
  negative word in it. → generalized in `c52a1f4`.

### The shape of the failures so far

| | s1 | s2 | s3 |
|---|---|---|---|
| Matrix 0 | 9/9 | 9/9 | **8/9** |
| Matrix 1 | 9/9 | 9/9 | **7/9** |
| Matrix 2 | **8/9** | 9/9 | 9/9 |

Every matrix loses exactly one fixture, always on `basis-honest`, always on a different specific
claim — and every diagnosed class has stayed dead once fixed (s3's recovery is the clearest case).
That is the signature of a strict judge auditing 30–80 verifiable claims per digest and finding the
one that slipped, rather than of a skill with a standing defect. Worth watching: if matrix 3 loses a
fixture to yet another one-off `basis-honest` claim, the evidence points at the bar (six consecutive
defect-free digest-judgements) exceeding what this artifact class reaches, not at a fixable gap —
that is a call for the human reviewer, not another loop iteration.

## Matrix 3 — skill @`c52a1f4`

L1/L2 **57 PASS / 0 FAIL**. Judges: s1 **9/9**, s2 **8/9 FAIL**, s3 **9/9**.

The enumeration rule works: s3's runner caught, in its own draft, that "`middleware=` 다섯 군데"
silently omitted `WebSocketRoute` — the exact defect class that failed s1 in matrix 2 — and s2's
runner withdrew a file-count claim rather than publish a number inflated by the harness's
`.materialized` marker. s1 and s3, the two fixtures that had failed earlier matrices, both pass.

- **s2 — FAIL (8/9), `fidelity`.** §5's compressed line says the three merge scripts share three
  idioms including trailing-newline mimicry and empty-input defence; `modify_AGENTS.md` has neither,
  **and the digest's own collapsed box says so**. The summary is refuted by its own detail.

This one is different in kind from the first three: **the rule already existed** ("every claim at the
current level stays true when the box is opened"). It is a compliance miss, not a gap, so there is no
new rule to add — only a sharpening of the check from an abstract test into a concrete action
(re-read each deferred box against the sentence that introduces it), applied in the next commit.
Repeating an existing rule louder is not a fix.

## Where this stands

| | s1 | s2 | s3 | failing item |
|---|---|---|---|---|
| Matrix 0 | 9/9 | 9/9 | **8/9** | basis-honest — absence claim |
| Matrix 1 | 9/9 | 9/9 | **7/9** | basis-honest — scoped absence · anchors — symbol |
| Matrix 2 | **8/9** | 9/9 | 9/9 | basis-honest — enumeration completeness |
| Matrix 3 | 9/9 | **8/9** | 9/9 | fidelity — summary vs. its own detail |

Four matrices, each losing exactly one item out of twenty-seven. Three of the four causes were real
rule gaps; each was closed, and each closure held — the class never recurred, and runners now catch
it in their own drafts before a judge sees it. Every fixture that failed has since passed. The fourth
was not a gap.

**The terminal condition is not converging, and the reason is not a standing defect.** Two
consecutive clean matrices means six consecutive defect-free digest-judgements, where each digest
makes 50–100 individually checkable claims and a strict judge audits them against the source. The
observed rate is roughly one slipped claim per matrix, scattered across different dimensions and
different fixtures. Grinding further would be sampling that variance, not closing gaps — and the
risk of "fixing" non-systematic one-offs is a skill that grows louder and worse, which the
prompt-engineering evidence warns against directly.

The compression-check sharpening (`e32634e`) is itself untested; matrix 4 runs it before any call is made.
gate all along. The loop bought what a loop can buy: three diagnosed and closed defect classes, and
an artifact that passes 52 of the last 54 item-judgements.

## Matrix 4 — skill @`e32634e`

L1/L2 **57 PASS / 0 FAIL** (fifth consecutive). Judges: s1 **9/9**, s2 **8/9 FAIL**, s3 **9/9**.

Both previously-failing claims are now right: s1's enumeration reads "exactly four functions touch
`lastView` (75/143/257/766)" — the claim that was "three places" when it failed matrix 2 — and the
judge re-ran the race reproduction itself to confirm it. s3's collapsed boxes were read back against
their introducing sentences with no contradiction, the check that failed s2 in matrix 3.

- **s2 — FAIL (8/9), `basis-honest`.** "이 트리에 실제로 쓰인 접두사는 다섯 종류뿐이다" — `private_`
  is a sixth, in `dot_codex/modify_private_config.toml`, and the digest's own table two rows later
  relies on it. Every other quantity was exact.

## Conclusion: the loop has bought what a loop can buy

| | s1 | s2 | s3 | failing item | kind |
|---|---|---|---|---|---|
| Matrix 0 | 9/9 | 9/9 | **8/9** | basis-honest — absence | **rule gap** → closed |
| Matrix 1 | 9/9 | 9/9 | **7/9** | basis-honest — scoped absence · anchors — symbol | **rule gap** → closed |
| Matrix 2 | **8/9** | 9/9 | 9/9 | basis-honest — enumeration | **rule gap** → closed |
| Matrix 3 | 9/9 | **8/9** | 9/9 | fidelity — summary vs. own detail | rule existed |
| Matrix 4 | 9/9 | **8/9** | 9/9 | basis-honest — enumeration, again | rule existed |

Five matrices, each losing exactly one item of twenty-seven, spread across all three fixtures and two
different rubric items. The first three causes were genuine gaps in the skill; each was diagnosed,
closed, and stayed closed — and runners now catch those classes in their own drafts before a judge
ever sees them, which is visible in every matrix-3 and matrix-4 runner report.

**The last two are violations of rules the skill already states in as many words.** Matrix 4's failing
sentence is the exact pattern the skill's own text names as an example ("the four states it can be
in": a claim about everywhere you did not look). There is no rule left to add, and adding emphasis to
an existing one is the move the prompt-engineering evidence specifically says does not work.

What remains is the error rate of authoring 50–100 individually checkable claims about unfamiliar
software while a strict auditor checks all of them. Two consecutive clean matrices means six
consecutive defect-free digest-judgements; the observed rate is about one slipped claim per matrix.
Further iterations would sample that variance rather than close gaps, and "fixing" non-systematic
one-offs is how a skill gets louder and worse.

One structural change was made in response and is **untested**: the verify pass now says to *list*
every claim of each kind and clear the list, rather than to re-read and trust the re-read — a
checklist, which the skill-design guidance recommends precisely because clear steps stop a validation
being skipped. It targets the observed shape of these failures (most claims verified, one never put
on the list). It has not been through a matrix; the real-case run and human review will exercise it.

**Delivered:** skill v1 (`SKILL.md` + four references, both vendor trees), a harness proven by red
test and never touched since, five matrices, three defect classes diagnosed and closed, L1/L2 57/57
five times running, and 52 of the last 54 L4 item-judgements passing.
**Not delivered:** the literal terminal condition of two consecutive all-pass matrices.

## Carried forward (for L5 review, not blocking)

- **Self-referential counts.** The quantity rule says "recomputed from the source"; a count of the
  digest's *own* parts (the "세 문제" slip) sits just outside that wording. One cosmetic instance so
  far — not the systematic pattern that justified the previous two fixes. Watch for recurrence.
- **Bundle input is now in the skill, and is untested.** A correction from the author closed a real
  gap: "single subject" was always about the *subject* — one system or one piece of work — never about
  the input arriving in one piece. A system routinely spans a service, its charts, and its
  infrastructure. The description said "set of PRs" but the body framed every input in the singular,
  and the anchor contract had no way to say *which* repository a path belonged to.

  Changed: step 1 separates the subject from the pieces it arrived in; step 3 makes the relationships
  between pieces part of the subject (ordering across repositories *is* the architecture, and it is
  written in none of them; the uniting intent usually lives outside all of them, in a ticket or a
  message); step 4 extends organize-by-intent to "not by repository either"; the output contract adds
  `data-repo`, required whenever the subject spans more than one repository, because a
  repository-relative path is not unique across a bundle.

  **No fixture exercises this.** The pinned set tops out at a single PR and a single repository, and
  `check.py` resolves anchors against one fixture root, so it cannot yet verify `data-repo`. The real
  target — NEWCS-3868, 12 PRs across 12 repositories in 5 ordered rollout groups — is the natural
  first exercise, and a bundle fixture plus `data-repo` resolution is the natural next harness change.
- **Access.** `socar-inc` repositories do not resolve for the active `socar-nio` token despite `repo`
  and `admin:org` scopes, and `user/orgs` is empty — the signature of a missing SAML SSO grant.
  `gh auth refresh -h github.com -s repo` and authorizing the org unblocks both real targets.
