#!/usr/bin/env bash
# Install the specialist skills this project's stack needs, per skills.manifest.json.
# Usage:  bash scripts/bootstrap.sh [--dry-run] [-g|--global] <stack-key…>
#   stack-key ∈ leaf keys of the manifest (e.g. .net ios-swiftui flutter web)
# With no keys, prints the available keys. --dry-run echoes commands without running them.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$here/skills.manifest.json"
command -v jq >/dev/null || { echo "error: jq is required"; exit 1; }
[ -f "$manifest" ] || { echo "error: $manifest not found"; exit 1; }

dry=0; global=""
keys=()
for a in "$@"; do
  case "$a" in
    --dry-run) dry=1 ;;
    -g|--global) global="-g" ;;
    -*) echo "unknown flag: $a"; exit 1 ;;
    *) keys+=("$a") ;;
  esac
done

run() { if [ "$dry" = 1 ]; then echo "  + $*"; else echo "  + $*"; "$@"; fi; }

if [ "${#keys[@]}" -eq 0 ]; then
  echo "Available stack keys:"
  jq -r 'to_entries[] | select(.value|type=="object") | .value | keys[] | "  " + .' "$manifest"
  echo; echo "Usage: bash scripts/bootstrap.sh [--dry-run] [-g] <stack-key…>"
  exit 0
fi

for key in "${keys[@]}"; do
  skills="$(jq -c --arg k "$key" \
    'to_entries | map(.value) | map(select(type=="object")) | map(.[$k]) | map(select(.!=null)) | add // empty' \
    "$manifest")"
  if [ -z "$skills" ]; then echo "• $key: no skills mapped — skipping"; continue; fi
  echo "• $key:"
  echo "$skills" | jq -c '.[]' | while read -r s; do
    name="$(jq -r '.name' <<<"$s")"
    kind="$(jq -r '.kind' <<<"$s")"
    case "$kind" in
      skills-cli)
        run npx skills add $global "$(jq -r '.ref' <<<"$s")" ;;
      plugin)
        run claude plugin marketplace add "$(jq -r '.marketplace' <<<"$s")"
        run claude plugin install "$(jq -r '.plugin' <<<"$s")@$(jq -r '.marketplaceName' <<<"$s")" ;;
      todo)
        echo "  ! $name has no confirmed source yet ($(jq -r '.source' <<<"$s")) — skipping" ;;
      *)
        echo "  ! $name: unknown kind '$kind' — skipping" ;;
    esac
  done
done
echo "Done. Skills are invoked by the backend/frontend agents when CLAUDE.md §5 matches."
