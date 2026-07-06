#!/usr/bin/env bash
# Validate the plugin's own consistency — run locally before committing; CI runs it on every push.
# Catches the drift class of bugs: stale counts/names in manifests, missing templates, leftover
# strings from renames/splits.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$here"
fail=0
err() { echo "FAIL: $*" >&2; fail=1; }

command -v jq >/dev/null || { echo "error: jq is required"; exit 1; }

# 1. JSON well-formedness
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json skills.manifest.json hooks/hooks.json; do
  jq empty "$f" 2>/dev/null || err "$f is not valid JSON"
done

# 2. Agent count claimed in docs matches agents/ on disk
count="$(find agents -name '*.md' | wc -l | tr -d ' ')"
grep -q "($count specialists)" .claude-plugin/plugin.json || err "plugin.json description must say ($count specialists)"
grep -q "$count-agent" .claude-plugin/marketplace.json || err "marketplace.json description must say $count-agent"
grep -q "The $count agents" README.md || err "README.md must have a 'The $count agents' section"
grep -q "$count specialist agents" templates/CLAUDE.md || err "templates/CLAUDE.md must say '$count specialist agents'"

# 3. No leftovers from renames/splits
if grep -q "/init " .claude-plugin/plugin.json; then err "plugin.json still references /init"; fi
if grep -rq "cc-init" --include="*.md" --include="*.json" .; then err "stale /cc-init reference remains"; fi
if grep -q "ios-swiftui" scripts/bootstrap.sh skills.manifest.json; then err "stale ios-swiftui key remains"; fi
if grep -riq "eight-agent\|8 specialists" .claude-plugin/; then err "stale 8-agent count in manifests"; fi
if grep -rq "two pipeline" skills/ docs/ templates/; then err "stale 'two pipeline gates' phrasing remains (there are three)"; fi
if grep -rq "Both completion-report" skills/; then err "stale two-builder phrasing in SKILL.md"; fi
if grep -rqF "(\`frontend\` or \`backend\`)" agents/; then err "reviewer owner vocabulary missing ios/flutter"; fi

# 4. Every pipeline artifact stage has a template
for t in business-requirements product-spec architecture-spec task design review completion-report; do
  [ -f "docs/_templates/$t.template.md" ] || err "missing docs/_templates/$t.template.md"
done

# 5. Hook script is executable and referenced correctly
[ -x hooks/guard-writes.sh ] || err "hooks/guard-writes.sh is not executable"
jq -e '.hooks.PreToolUse[0].hooks[0].command | contains("guard-writes.sh")' hooks/hooks.json >/dev/null \
  || err "hooks.json does not wire guard-writes.sh"

# 6. Shellcheck, when available
if command -v shellcheck >/dev/null; then
  shellcheck scripts/bootstrap.sh scripts/validate.sh hooks/guard-writes.sh || fail=1
else
  echo "note: shellcheck not installed — skipping shell lint"
fi

# 7. Every roles key in the manifest matches an agent file (catches agent renames),
#    and every agent named in the guard hook's case arms exists
for key in $(jq -r '.roles | keys[]' skills.manifest.json); do
  [ -f "agents/$key.md" ] || err "manifest roles key '$key' has no matching agents/$key.md"
done
for role in code-reviewer qa-tester api-tester business-analyst product-manager architect designer; do
  grep -q "$role" hooks/guard-writes.sh || err "guard-writes.sh missing case arm for $role"
  [ -f "agents/$role.md" ] || err "guard-writes.sh references nonexistent agent $role"
done

if [ "$fail" = 0 ]; then echo "OK — all consistency checks passed."; else exit 1; fi
