#!/bin/bash
# run_once_after_metacognition.sh — bootstrap the Metacognition KB family on a new machine.
#
# Clones the two repos if absent, then renders the per-provider skill adapters and
# records the vault location via the installer. Idempotent by construction: each repo
# is cloned only when missing, and the installer is safe to re-run — so on a machine
# that already has the repos (e.g. the maintainer's) the clones are skipped and the
# install is a no-op. The engine then mutates the vault directly; chezmoi never hosts
# the family content. URLs are overridable for forks / testing.
set -euo pipefail

share="$HOME/.local/share"
tooling="$share/metacognition"
vault="$share/metacognition-vault"
tooling_url="${METACOGNITION_TOOLING_URL:-https://github.com/mynghn/metacognition.git}"
vault_url="${METACOGNITION_VAULT_URL:-https://github.com/mynghn/metacognition-vault.git}"

[ -d "$tooling/.git" ] || git clone "$tooling_url" "$tooling"
[ -d "$vault/.git" ]   || git clone "$vault_url" "$vault"

python3 "$tooling/install" --vault "$vault"
