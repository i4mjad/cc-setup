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
- **Agent counts are written numerically** ("13 agents", "(13 specialists)", "13-agent") so
  validate.sh can check them against `agents/*.md`. Adding an agent means updating plugin.json,
  marketplace.json, README, templates/CLAUDE.md, and commands/initialize.md. Don't write a count as a
  word ("Twelve") anywhere validate.sh greps — the spelled-out form in README's opening line is
  prose, and must be updated by hand.
- **Every artifact stage needs a template** in `docs/_templates/` named `<stage>.template.md`.
- **Every codex-gated stage needs a rubric** in `prompts/` named `<stage>-gate.md`. The stage set is
  `discovery | requirements | product | design` — adding a gate touches the rubric, SKILL.md's gate
  list, `agents/codex-reviewer.md`, and `commands/peer-review.md`'s path→stage table.
- **`agents/codex-reviewer.md` hardcodes paths** into `prompts/` and `schemas/` — validate.sh checks
  they still resolve, because a rename that misses one breaks every gate silently.
- **Bump `plugin.json` version** on any behavior change (agents, SKILL.md, hooks, bootstrap).
- **Third-party skill refs in `skills.manifest.json` are unpinned** — when touching them, verify the
  upstream repo still exists and the invoke names still match.
- Write boundaries are enforced by `hooks/guard-writes.sh` (agent roles are matched by name) —
  renaming an agent requires updating the hook's case arms.
