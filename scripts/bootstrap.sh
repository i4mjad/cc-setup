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
  echo "Stack keys (install per project stack — CLAUDE.md §5):"
  jq -r '((.backend // {}) + (.frontend // {})) | keys[] | "  " + .' "$manifest"
  echo "Role keys (per pipeline agent — or pass 'roles' for all):"
  jq -r '.roles | keys[] | "  " + .' "$manifest"
  echo; echo "Usage: bash scripts/bootstrap.sh [--dry-run] [-g] <key…|roles>"
  exit 0
fi

# expand the `roles` meta-key to every agent-role key
expanded=()
for k in "${keys[@]}"; do
  if [ "$k" = "roles" ]; then
    while IFS= read -r rk; do expanded+=("$rk"); done < <(jq -r '.roles | keys[]' "$manifest")
  else
    expanded+=("$k")
  fi
done
keys=("${expanded[@]}")

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
      mcp)
        echo "  ~ $name is an MCP server — configure separately ($(jq -r '.invoke' <<<"$s"))" ;;
      todo)
        echo "  ! $name has no confirmed source yet ($(jq -r '.source' <<<"$s")) — skipping" ;;
      *)
        echo "  ! $name: unknown kind '$kind' — skipping" ;;
    esac
  done
done
echo "Done. Stack skills are invoked by the build agents when CLAUDE.md §5 matches; role skills by their pipeline agent."
