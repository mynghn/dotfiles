# L4 judge rubric — frozen

You are judging **one** digest produced by the `software-digest` skill. You did not write it and you
must not repair it: your job is to decide, item by item, whether it holds.

You are given: the digest HTML, the pinned fixture source tree, and the scenario brief (which states
the persona the digest was written for). **Open the fixture and check** — several items below require
you to verify claims against real code, not to read the digest sympathetically.

Judge only what each item states. A digest that is pleasant but fails an item fails that item.

## Items

1. **intent-organization** — Sections are organized by what the work is trying to accomplish. A
   digest whose spine is a file-by-file or directory-by-directory walk fails, even if each entry is
   accurate.
2. **salience-marked** — A reader can tell where to spend attention: the digest distinguishes what
   carries the load from what is routine or mechanical. Uniform treatment of everything fails.
3. **basis-honest** — Spot-check at least three `data-basis` markers. `stated` claims trace to the
   named `data-source`; `inferred` claims are genuinely the digest's own reasoning rather than
   something the source says outright; unmarked load-bearing claims are verifiable in the code.
4. **anchors-say-what-is-claimed** — Open at least three cited anchors in the fixture. The place
   cited actually says what the digest claims about it. (That the path and line *exist* is already
   machine-checked; you are checking meaning.)
5. **diagram-corresponds** — For each figure, spot-check at least two nodes or edges against the
   fixture: they correspond to real entities and real calls, imports, or data paths. A figure that is
   schematically plausible but not grounded in this code fails.
6. **fidelity** — The hard or surprising part of the work is shown — with a figure, a trace, or an
   excerpt — rather than asserted. Where the digest compresses, the compression is an honest
   encapsulation: every claim it makes at that level stays true if the deferred box were opened.
7. **descriptive-not-verdict** — The digest reports what is there, what it costs, and which
   alternatives were live, and leaves the judgment to the reader. Grading the work — calling it good,
   bad, clean, sloppy, or recommending a change — fails this item.
8. **reader-contract-honest** — The reader contract matches the scenario's persona (its purpose,
   assumed baseline, and budget), and it states what the digest leaves out. A contract that claims
   coverage the digest does not deliver fails.
9. **self-check-answerable** — Each self-check question is answerable from the digest, and tests
   understanding rather than recall of a phrase. Questions spanning predict, explain, and locate.

## Output format

Emit exactly this, and nothing else:

```
ITEM intent-organization: PASS|FAIL — <one line of evidence>
ITEM salience-marked: PASS|FAIL — <one line of evidence>
ITEM basis-honest: PASS|FAIL — <one line of evidence>
ITEM anchors-say-what-is-claimed: PASS|FAIL — <one line of evidence>
ITEM diagram-corresponds: PASS|FAIL — <one line of evidence>
ITEM fidelity: PASS|FAIL — <one line of evidence>
ITEM descriptive-not-verdict: PASS|FAIL — <one line of evidence>
ITEM reader-contract-honest: PASS|FAIL — <one line of evidence>
ITEM self-check-answerable: PASS|FAIL — <one line of evidence>
VERDICT: PASS|FAIL (<n>/9)
```

`VERDICT: PASS` only when all nine items pass.
