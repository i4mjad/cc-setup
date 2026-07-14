#!/usr/bin/env bash
# Install (or update) the specialist skills this project's stack needs, per skills.manifest.json.
# Usage:  bash scripts/bootstrap.sh [--dry-run] [--update] [-g|--global] <stack-key…>
#   stack-key ∈ leaf keys of the manifest (e.g. .net ios flutter web) or an agent-role key
#   (e.g. designer), or `roles` for every agent-role key at once.
# With no keys (or --help), prints the available keys. --dry-run echoes commands without running them.
# --update refreshes already-installed skills from their upstreams (skills-cli re-fetches the tracked
#   branch; plugins use `claude plugin update`). Pair with `roles`/stack keys, e.g. `--update roles`.
# Requires: jq; network plus npx / the claude CLI for the actual installs.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$here/skills.manifest.json"
command -v jq >/dev/null || { echo "error: jq is required"; exit 1; }
[ -f "$manifest" ] || { echo "error: $manifest not found"; exit 1; }

usage() {
  echo "Stack keys (install per project stack — CLAUDE.md §5):"
  jq -r '((.backend // {}) + (.frontend // {})) | keys[] | "  " + .' "$manifest"
  echo "Role keys (per pipeline agent — or pass 'roles' for all):"
  jq -r '.roles | keys[] | "  " + .' "$manifest"
  echo; echo "Usage: bash scripts/bootstrap.sh [--dry-run] [--update] [-g|--global] <key…|roles>"
  echo "       add --update to refresh already-installed skills from upstream"
}

dry=0; global=""; update=0
keys=()
for a in "$@"; do
  case "$a" in
    --dry-run) dry=1 ;;
    --update) update=1 ;;
    -g|--global) global="-g" ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown flag: $a" >&2; usage; exit 1 ;;
    *) keys+=("$a") ;;
  esac
done

if [ "${#keys[@]}" -eq 0 ]; then usage; exit 0; fi

failed=()
run() {
  echo "  + $*"
  if [ "$dry" = 0 ]; then "$@" || { failed+=("$*"); echo "  ! FAILED: $*" >&2; }; fi
}

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
  while IFS= read -r s; do
    name="$(jq -r '.name' <<<"$s")"
    kind="$(jq -r '.kind' <<<"$s")"
    case "$kind" in
      skills-cli)
        # `skills add` re-fetches the tracked branch, so it doubles as the update path.
        # shellcheck disable=SC2086  # $global is intentionally empty-or-"-g"
        run npx skills add $global "$(jq -r '.ref' <<<"$s")" ;;
      plugin)
        if [ "$update" = 1 ]; then
          run claude plugin update "$(jq -r '.plugin' <<<"$s")@$(jq -r '.marketplaceName' <<<"$s")"
        else
          run claude plugin marketplace add "$(jq -r '.marketplace' <<<"$s")"
          run claude plugin install "$(jq -r '.plugin' <<<"$s")@$(jq -r '.marketplaceName' <<<"$s")"
        fi ;;
      mcp)
        echo "  ~ $name is an MCP server — configure separately ($(jq -r '.invoke' <<<"$s"))" ;;
      *)
        echo "  ! $name: unknown kind '$kind' — skipping"; failed+=("$name (unknown kind: $kind)") ;;
    esac
  done < <(echo "$skills" | jq -c '.[]')
done

echo
if [ "${#failed[@]}" -gt 0 ]; then
  echo "DONE WITH FAILURES — these did not install (agents fall back to their own prompts):"
  printf '  ! %s\n' "${failed[@]}"
  exit 1
fi
echo "Done. Stack skills are invoked by the build agents when CLAUDE.md §5 matches; role skills by their pipeline agent."
