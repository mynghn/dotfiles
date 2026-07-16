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
