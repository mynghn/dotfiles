# 0001-local-recall-search — Understanding Shifts

## Delta-1: qmd-runtime-is-path-dependent-not-bun

Design assumed bun is the runtime that runs the prose engine, and that installing the engine with bun is sufficient.
Implementation (P1 entry, verifying engine surfaces per the doc-level Guideline) falsified both halves against the real installed engine.

Evidence gathered on this machine (Apple Silicon, macOS):

- The engine's published binary declares `#!/usr/bin/env node`, so **bun never runs it** — the runtime is whatever `node` the PATH resolves at invocation time.
  Running the same entrypoint explicitly under bun fails identically, so the runtime choice was never the operative variable.
- The engine's package declares `engines = { node: '>=22.0.0' }`; this machine's ambient node is an nvm-managed v20.17.0, with no node ≥22 present at all.
- Installing with bun leaves a **broken** engine: its native SQLite dependency publishes no darwin/arm64 prebuilt binary for node 20 (`prebuild-install: No prebuilt binaries found (target=20.17.0 runtime=node arch=arm64 platform=darwin)`), so it fell back to a source build that failed.
  The engine's help text still printed, but every index/query operation exits 1 — a plausible-looking install that cannot serve a single query.
- Installing with a pinned node ≥22's own package manager fetches the prebuilt native binary cleanly (no source build), and the same operation then exits 0.

The engine's launcher makes this structural, not incidental.
Its published bin is a polyglot shell/JS launcher whose second line reads `if command -v node >/dev/null 2>&1; then exec node "$0" "$@"; else exec bun "$0" "$@"; fi`.
Two consequences follow, both verified:

- **An absolute-path invocation cannot pin the runtime.** The launcher re-resolves `node` from PATH and re-execs, so invoking it via an absolute pinned-node path still lands on the ambient node.
  Proven: same absolute pinned-node invocation exits 1 without the pinned node on PATH, and exits 0 with it prepended.
  Only PATH control pins the runtime.
- **Bun is the launcher's fallback, not its runtime** — reached only when no node exists on PATH at all.
  So the original "bun runs the engine" premise could never hold on any machine that has node.

The native dependency is additionally ABI-locked to the node that installed it, so the installing node and the invoking node must match — a mismatch fails at load with a module-version error even though both are ≥ the engine's floor.

The durable finding is therefore that **an `env`-resolved, re-execing launcher makes the engine's runtime a property of the invoking shell's PATH**, and a version manager makes that PATH ambient and per-machine.
Installing a correct interpreter is not sufficient, and this is the sharpest form of the finding: the pinned interpreter here *is* present and *is* linked onto PATH, yet the ambient `node` still resolves to the version manager's older one, because the manager's directory sits earlier in PATH.
PATH **position** is the variable, not the interpreter's presence — so any fix phrased as "install the right node" fails silently on exactly the machines that already have a version manager.
A correctly installed engine can still be broken at query time by whichever node the shell happens to resolve — exactly the pre-existing-local-environment dependence the feature's portability guarantee forbids, and the machine-to-machine divergence `Spec#C-3-uniform-across-machines` forbids.

The finding extends to any fix that itself relies on PATH order.
The engine's default global install places its own bin in a directory that is already on PATH, so a same-named pinned wrapper would not replace it — it would merely compete, resolving by PATH order and therefore by machine.
Fixing an ambient-PATH failure with an ambient-PATH race is no fix; the losing side is the broken build, and the loss is silent.
The realization must therefore keep the engine's own bin **off** PATH entirely (a private install prefix), so the pinned entry point has no competitor rather than merely outranking one.
Verified: with the engine vendored into a private prefix, a pinned wrapper exits 0 from a shell whose ambient node is too old and whose PATH already resolves a competing broken copy, which exits 1 in that same shell.

Consequence: the realization must pin the interpreter by controlling PATH at invocation, must install and invoke under the same pinned node, and must vendor the engine off PATH so nothing competes with the pinned entry point.
Framed at the level that generalizes: the engine's node floor is satisfied *privately*, as a vendored dependency of one tool, rather than *systemically*, as a standing requirement on the machine's own node.
This corrects Design (`Design#D-5-provisioning-run-after-brew`'s toolchain and install lines, and any invocation surface that assumes a bare engine command on PATH), and reaches `Design#D-3-routing-skill-local-search` only insofar as the skill names the invocation.
No Spec or Requirements change: the contract items were already right — this is a realization that failed to meet them, which is why the drift stops at Design.

## Delta-2: engine-surfaces-verified-against-installed-versions

Design's engine command surfaces were research-derived drafts, and the doc-level Guideline required verifying them against the installed pinned versions before building on them.
Verification against both installed engines confirms most of the draft and falsifies two specifics.

Confirmed, no change needed: the prose engine does expose collections and a collection filter on its search commands; the code engine does expose the semantic and hybrid search modes the Design names, and auto-indexes on query as assumed.

Falsified, correcting Design:

- **Both engines omit line locations by default, and both can emit them on request.** Design routed a prose result through a second exact-match invocation to recover a line anchor, and separately assumed the code engine emitted line spans natively.
  Verified against the installed versions, neither held: the prose engine defaults to a scheme-qualified document id rather than a usable path, and the code engine prints the file and matching chunk with no line number at all — so *as designed, both lanes would have missed* `Spec#C-4-actionable-result-locations`.
  Each engine does expose the needed output directly, but asymmetrically — the prose engine emits the line number by default and needs only an on-disk-path flag, while the code engine needs a line-number flag — so the second invocation is machinery the contract does not need.
  The correction is that every routed command carries exactly the flag its engine actually requires, and the extra hop survives only as a stated fallback.
  Confirmed on a populated index rather than from flag existence: with the path flag the prose engine emits an absolute `path:line`, and without it a `qmd://` docid that no agent can open.
  The asymmetry is the reason to verify per engine rather than generalize one engine's surface onto the other.
- **The prose engine has no model-pull command**, resolving the question Design explicitly left open ("a warm-up invocation or the engine's pull command, whichever the installed version offers").
  Neither engine offers one: both fetch models on first real use, so provisioning must force a warm-up invocation per engine.

The durable finding is that the engines' *published surfaces* are authoritative over anything inferred from documentation, and that a "reasonable" auxiliary mechanism can be pure cost once the real surface is read.
Both corrections stop at Design; the observable contract is unchanged.

## Delta-3: ignore-target-is-machine-variant-source-is-not

Design deferred the global-ignore target to implementation, to be chosen by reading the live git configuration: the standard path by default, or the configured override when one exists.
That instruction cannot be carried out as stated, and the reason generalizes.

The dotfiles source is machine-**invariant** — one committed tree applied to every machine — while the ignore target is machine-**variant**:

- This machine sets an explicit override, so the standard path is present but **inert**; git never reads it.
- The override is declared in a file the dotfiles do not manage, so a machine provisioned from these dotfiles alone has no override and git reads the standard path instead.

An implement-time choice between the two therefore cannot hold: whichever single file is committed is inert on exactly the machines that consult the other, and inert in the silent way — the ignore appears configured while the index directory stays untracked-and-visible, surfacing only as an accidental commit.
Reading the live configuration at implement time reads *this* machine's answer and freezes it for all of them, which is the same class of error as pinning behavior to an ambient environment (`Understanding#Delta-1-qmd-runtime-is-path-dependent-not-bun`).

Correction: manage both candidate paths with the same rule, so the ignore is effective under either configuration rather than correct on one machine and silently absent on the next.
The cost is one duplicated line; the alternative is a guarantee that holds only where it was authored.
This corrects Design's ignore decision and stops there.

## Delta-4: result-volume-is-half-the-output-contract

Design's output contract (`Design#D-3-routing-skill-local-search`) treats a result's **location** as the only thing the engines' defaults get wrong, and corrects it per-engine with a location flag.
Implementation (V1, exercising the taught commands against a code tree with no prior index) found a second default that defeats the same intent — on the code lane only.

This is a **gap, not a contradiction**: `Spec#C-4-actionable-result-locations` is literally met by the taught command — every one of its results does carry `file:line`.
The defect is that the command buries the answer among the rest, so recording it honestly means correcting Design's realization, not the contract.

Evidence gathered against the installed engines:

- The code engine's hybrid mode defaults to **unlimited results and no threshold** (it announces `top unlimited results, threshold ≥none`), unlike its semantic mode, which defaults to top 10 at ≥0.6.
  On a 13-file tree the taught command returns 127 result lines / 97,159 bytes; the same query capped at ten returns 5,870 — a 16.5× difference that scales with the tree, so a real repository is far worse.
- The engine's own help designates capped output the agent-facing form, pairing a result cap and a threshold under the heading of high-confidence agent results.
- The engine ignores `NO_COLOR`: ANSI escapes are emitted even into a pipe, padding every result of that flood with markup no reader needs.

The prose engine has the opposite default — it caps at five — which is why the gap survived Design review: the two lanes were assumed symmetric on everything but the flag each needed.

The durable finding is that **an actionable location is not only openable but findable**.
A location flag makes each hit openable; a result cap makes the right hit findable — and a contract phrased only over the individual result silently passes a command that returns the corpus.
This is Delta-2's asymmetry lesson applied to a second axis: the engines' defaults diverge over volume exactly as they diverged over location, so the contract must be stated per-engine over both rather than generalized from either.

Correction: the routed code command carries a result cap alongside its line flag, and the output contract is stated over volume as well as location.
This corrects Design (`Design#D-3-routing-skill-local-search`'s output contract and `Design#D-2-code-recall-engine-ck`'s taught command) and stops there — Spec and Requirements are unchanged, since the contract was right and the realization under-served it.

## Delta-5: an-install-root-is-only-useful-where-the-shell-already-looks

Design placed the code engine's binary at its package manager's **default** install root and treated that directory as being on PATH.
Both halves are false here, and this is a latent error caught late rather than a reality shift: provisioning (P1) already installs correctly, and only Design's prose was left behind.

Evidence on this machine:

- The package manager's default root is **not on PATH at all**, so a binary installed there would be unreachable by the bare command the skill teaches.
- Provisioning already passes an explicit install root, landing the binary in the directory these dotfiles themselves put on PATH; `Design#D-5-provisioning-run-after-brew` records that install line correctly.
  Verified: the binary exists at the explicit root and serves queries offline, while the default-root path does not exist at all.
- So Design contradicted itself — `Design#D-2-code-recall-engine-ck` named a location that does not exist on the very machine `Design#D-5-provisioning-run-after-brew` provisions, and asserted a PATH membership that was never true.

The durable finding is that **an install root is only useful if it is a directory the shell already searches**.
A package manager's default root is a property of that tool, not of the machine's PATH — so a realization that relies on it inherits a PATH assumption it does not control.
This is `Understanding#Delta-1-qmd-runtime-is-path-dependent-not-bun`'s lesson from the other side: there, the fix was to keep an engine *off* PATH so nothing competed with it; here, it is to place one *into* a directory the dotfiles already guarantee is on PATH.
Both replace an inherited PATH assumption with an owned one — the engine's reachability must be a property the dotfiles establish, not one they hope the machine already has.

Correction: Design names the explicit install root and drops the claim about the default root's PATH membership.
This corrects `Design#D-2-code-recall-engine-ck` and stops there — the provisioning realization and the observable contract are both already right.

## Delta-6: the-layer-is-portable-the-corpora-are-not

Design names three collection roots as though provisioning puts all three corpora on every machine.
Fresh-machine verification (V2, provisioning a clean `HOME` from these dotfiles alone) shows the recall **layer** is fully portable while the **corpora** are portable to three different degrees.

Evidence from that clean machine:

- The layer arrives complete and works: engines, pinned runtime wrapper, models, and the routing skill all land, and the very first query succeeds with no network at all (`Spec#B-4-first-query-readiness`, verified there rather than argued).
- `chezmoi-docs` is present on any real machine — its root is the dotfiles' own source clone, which the standard setup places at exactly that path.
- `agent-skills` arrives **partial**: the dotfiles manage 8 of this machine's 44 skills; the rest are installed by other tools' own installers, so a fresh machine's corpus is a subset until those run.
- `kb-vault` is **absent**: its root is a separate repository these dotfiles do not manage, so provisioning logged `corpus absent` and skipped it.

The realization already handles this honestly rather than silently: an absent corpus is skipped with a log at provisioning time, and a later query against it exits 1 with an explicit not-found — the surfaced-gap branch `Spec#B-5-unindexed-corpus-surfaced` exists for.
Nothing reports an unregistered corpus as an empty one, which is the failure that would actually hurt.

`Spec#C-3-uniform-across-machines` still holds and is worth stating precisely, because the raw observation looks like a violation: the same query returns different entries on the two machines.
C-3 constrains the *capability's behavior* — engines, commands, flags, and the offline property are identical on both.
What differs is *content*.
This is the distinction between a grep that finds different lines because the files differ and a grep that behaves differently; only the second would breach the contract.

The durable finding is that **a search layer's portability and its corpora's portability are separate properties, and only the first is these dotfiles' to guarantee**.
Naming a corpus root in Design does not put that corpus on a machine — it names a dependency whose own provenance must be stated rather than assumed.
This is the third instance of one pattern (`Understanding#Delta-3-ignore-target-is-machine-variant-source-is-not`, `Understanding#Delta-5-an-install-root-is-only-useful-where-the-shell-already-looks`): the dotfiles source is machine-invariant, and every unstated assumption about what a machine already has is where that invariance leaks.

Correction: Design states each collection's corpus provenance and what a fresh machine actually gets.
Whether the dotfiles should additionally *own* the absent corpus — cloning the vault so `kb-vault` becomes portable — is a scope decision rather than a repair, and is recorded as an open deferral instead of settled here (`Deferrals#Defer-2-corpus-provenance-ownership`).
