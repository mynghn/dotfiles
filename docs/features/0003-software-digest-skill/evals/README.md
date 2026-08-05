# software-digest — evaluation harness

Two layers, matching the two things that can go wrong: the skill can fail to honor its own contract
(cheap to check, checked always), or it can produce a digest that honors every contract and still
leaves the reader not understanding (expensive to check, checked at major revisions).

## Layer 1 — contract audit (run always)

```sh
./run.sh                    # all scenarios
./run.sh s1-bubbletea-pr    # one
```

`run.sh` materializes the pinned fixtures into `~/.cache/software-digest-evals` (override with
`SD_EVAL_CACHE`) and runs `check.py`, which is deterministic throughout — assertions and rules, no
judgment. It ends with a `RESULT: PASS|FAIL` line.

The load-bearing check is **`anchors-resolve`**: every `path:line` the digest cites is opened against
the pinned fixture. Grounding that cannot be verified is grounding theater, and this is where it dies.

Then, per scenario, an **L4 judge** reads `rubric.md` and returns nine PASS/FAIL items. It runs as a
fresh, isolated agent — separate from whatever produced the digest — and it opens the fixture to check
claims rather than reading the digest sympathetically.

### Producing the digests the checks run against

Each scenario in `scenarios/` names a fixture, an invocation, and a persona. A fresh agent follows
`scenarios/RUNNER-PROTOCOL.md`, exercising the skill and standing in for the user, and writes
`<slug>-digest.html` plus `session-log.md` into `work/<scenario-id>/`. `work/` is output, not fixture,
and is not tracked.

## Layer 2 — understanding transfer (major revisions only)

The real outcome variable is whether a reader understands, which Layer 1 cannot see. The instrument:
a fresh agent gets the persona's baseline and **the digest only, with the fixture withheld**, answers
a probe battery spanning predict / explain / locate, and is scored against an answer key written by a
separate agent that did have the code. A control run answers the same probes from the raw fixture
with no digest, at the same budget; the digest's value is the score delta per unit of budget.

**Not built yet — deferred deliberately.** The probe batteries and answer keys are the missing piece;
they cost one deep authoring run per fixture and Layer 1 does not depend on them. Build them when a
revision is large enough to need transfer evidence rather than contract evidence.

An honest limit worth restating whenever this layer is used: an agent reader is not a human reader.
It reads at a different speed, fails differently, and cannot experience the illusion of understanding
that a fluent explanation produces in a person. Layer 2 measures whether the digest carries enough of
the right information, well enough organized — not whether it teaches.

## Fixtures, and why they are pinned

| Scenario | Fixture | Pin | Shape it exercises |
|---|---|---|---|
| `s1-bubbletea-pr` | charmbracelet/bubbletea | merge `c60f0c53` (PR #1691) | a change: prior state, delta, blast radius; intent from a description and a linked issue |
| `s2-chezmoi-repo` | this dotfiles repo | `1de81ed` | a whole system, small, and verifiable by its own owner |
| `s3-starlette` | encode/starlette | tag `1.3.1` | an unfamiliar project of real size |

Pins are for reproducibility, not realism: an unpinned fixture moves under the answer key, and a
score change stops telling you whether the skill changed or the world did.

## Declared coverage limits

- The **variant-persona run** (`s2` persona B) — same fixture, different purpose, testing that the
  digest actually responds to purpose — is defined but not part of the required matrix. It costs a
  second full run of `s2`.
- Layer 2 is not built (above).
- `check.py` verifies that an anchor's file and line **exist**; whether that line *says* what the
  digest claims is item 4 of the judge's rubric, not a machine check.
- Nothing here measures a human reader.

## Freezing

`rubric.md`, `check.py`, `run.sh`, `scenarios/`, and `fixtures/` are frozen once the red test passes:
the checker must be shown failing a deliberately bad digest before it is trusted to pass a good one.
After that commit they do not change while the skill converges — a checker edited to fit the artifact
is not a check.
