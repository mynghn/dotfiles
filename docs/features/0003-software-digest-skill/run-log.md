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

- **s1 — rerunning** (first attempt lost to a connection failure mid-write, not a skill fault;
  fixture verified clean at `c60f0c5` afterwards)
- **s2 — pending**
- **s3 — digest written**, 79 anchors, 8 sections, 2 figures, 5 self-check questions

## Carried forward (for L5 review, not blocking)

- **Self-referential counts.** The quantity rule says "recomputed from the source"; a count of the
  digest's *own* parts (the "세 문제" slip) sits just outside that wording. One cosmetic instance so
  far — not the systematic pattern that justified the previous two fixes. Watch for recurrence.
- **Multi-repo ordered PR bundles are untested.** A real target — NEWCS-3868, 12 PRs across 12
  repositories in 5 ordered rollout groups, with intent living in a Jira ticket and a Slack message
  rather than in any repository — is a harder input shape than any pinned fixture, which tops out at
  a single PR. For work like that the cross-repo rollout order *is* the architecture, and per-PR
  detail has to stay subordinate to the bundle's story. The frozen harness cannot test this. The
  honest next step is to run the real case once v1 is settled and write v1.1 guidance from what that
  run shows, rather than adding unverifiable guidance now.
- **Access.** `socar-inc` repositories do not resolve for the active `socar-nio` token despite `repo`
  and `admin:org` scopes, and `user/orgs` is empty — the signature of a missing SAML SSO grant.
  `gh auth refresh -h github.com -s repo` and authorizing the org unblocks both real targets.
