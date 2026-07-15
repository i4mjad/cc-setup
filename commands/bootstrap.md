---
description: Install (or update) the stack/role skills this project needs, per skills.manifest.json. Runs bootstrap.sh through Claude Code itself, so ${CLAUDE_PLUGIN_ROOT} resolves correctly.
argument-hint: <stack-key…|roles> [--update] [--dry-run]  (no args: list every key)
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh:*)
---

<!--
${CLAUDE_PLUGIN_ROOT} only resolves inside Claude Code's own tool calls — pasting
`bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh ...` into a plain terminal expands it to empty and
fails with "No such file or directory". This command exists so the script always runs the way it's
meant to: through Claude Code.
-->

Run this with the Bash tool and show the full output verbatim:

`bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh $ARGUMENTS`

If the output lists any `FAILED` installs, call them out explicitly — that skill didn't install and its
agent falls back to its own built-in prompt (not a silent failure, but worth flagging).
