# cc-setup — plugin development

This repo IS the Claude Code plugin (agents + `/feature` orchestrator + `/initialize` scaffolder +
skill manifest). It ships to consuming projects; `templates/CLAUDE.md` is what those projects get —
this file governs work on the plugin itself.

## Rules

- **Run `bash scripts/validate.sh` before every commit.** It enforces the consistency invariants
  below; CI runs it on every push.
- **The pipeline is described in four places** — `skills/feature/SKILL.md` (normative),
  `docs/ORCHESTRATION.md`, `templates/CLAUDE.md` §2, and `README.md`. Any change to gates, agents,
  owners, or artifacts must be applied to all four in the same commit. When in doubt, SKILL.md wins.
- **Owner vocabulary is exactly** `frontend | ios | flutter | backend` — everywhere: agents,
  templates, SKILL.md. Adding/renaming a platform touches the architect, the builders, all three
  reviewers, both report templates, and the router in SKILL.md.
- **Agent counts are written numerically** ("11 agents", "(11 specialists)", "11-agent") so
  validate.sh can check them against `agents/*.md`. Adding an agent means updating plugin.json,
  marketplace.json, README, and templates/CLAUDE.md.
- **Every artifact stage needs a template** in `docs/_templates/` named `<stage>.template.md`.
- **Bump `plugin.json` version** on any behavior change (agents, SKILL.md, hooks, bootstrap).
- **Third-party skill refs in `skills.manifest.json` are unpinned** — when touching them, verify the
  upstream repo still exists and the invoke names still match.
- Write boundaries are enforced by `hooks/guard-writes.sh` (agent roles are matched by name) —
  renaming an agent requires updating the hook's case arms.
