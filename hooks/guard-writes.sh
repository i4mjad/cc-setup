#!/usr/bin/env bash
# PreToolUse guard — mechanical enforcement of the pipeline's write boundaries:
#   1. review.md is written only by the /feature orchestrator (main thread), never a subagent.
#   2. Reviewers (code-reviewer, qa-tester, api-tester) never write or edit files.
#   3. Spec/design agents (business-analyst, product-manager, architect, designer) author docs,
#      never application code under apps/ or services/.
# Exit 2 blocks the tool call and returns the stderr message to the agent.
# Fails open (exit 0) when jq is unavailable or the input has no file path.
set -u
command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
agent="$(jq -r '.agent_type // empty' <<<"$input")"
path="$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input")"

[ -n "$path" ] || exit 0
[ -n "$agent" ] || exit 0 # main thread — the orchestrator is unrestricted

role="${agent##*:}" # strip a plugin namespace prefix like "cc-setup:"

case "$path" in
  */docs/reports/*/review.md | docs/reports/*/review.md)
    echo "Blocked: review.md is written only by the /feature orchestrator (main thread). Return your findings to the orchestrator instead." >&2
    exit 2
    ;;
esac

case "$role" in
  code-reviewer | qa-tester | api-tester)
    echo "Blocked: $role is a read-only reviewer — report findings to the orchestrator; the build agents apply fixes." >&2
    exit 2
    ;;
  business-analyst | product-manager | architect | designer)
    case "$path" in
      */apps/* | apps/* | */services/* | services/*)
        echo "Blocked: $role authors docs, not application code. Hand implementation to the build agents." >&2
        exit 2
        ;;
    esac
    ;;
esac

exit 0
