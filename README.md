# cc-setup

A reusable **Claude Code plugin**: a **requirements → design → build → verify** agent team plus a
stack-aware skill set. Eleven specialist agents run a single pipeline, orchestrated by the **`/feature`**
skill, that takes a raw brief all the way to reviewed, verified code — stopping at human approval gates
along the way. The build agents are **platform-scoped**, so a web-only app and a web + iOS + Flutter app
each get exactly the agents they need.

Install it once and it's available in **every** project — no copy-paste. The plugin's own files
(agents, commands, hooks, templates) update via `claude plugin update`; the third-party stack/role
skills installed by `bootstrap.sh` are separate installs, refreshed from their own upstreams with
`bootstrap.sh --update` (see [Bootstrap](#bootstrap)).

## Install

Prerequisites: the `claude` CLI, plus `jq`, `npx`, and network access for `bootstrap.sh`.

**1. Install the plugin (once, globally):**

```bash
claude plugin marketplace add i4mjad/cc-setup   # register this repo as a marketplace
claude plugin install cc-setup@cc-setup         # install the plugin
```

Then **restart Claude Code** so the agents, `/initialize`, and `/feature` load.

To update later: `claude plugin update cc-setup@cc-setup`. To develop locally, point the marketplace at
a checkout instead: `claude plugin marketplace add /path/to/cc-setup`.

**2. Scaffold a project (once per project):**

```
/initialize
```

`/initialize` writes a starter `CLAUDE.md` and interviews you for the **project shape** — full-stack web vs
full-stack + mobile, which mobile (iOS / Flutter / both), and which backend (.NET / Supabase / Firebase /
custom). It records that in `CLAUDE.md §5`, which decides exactly which build agents `/feature` dispatches.
(Named `initialize`, not `init`, to avoid clashing with Claude Code's built-in `/init`.)

**3. Install the skills your stack needs (once per project):**

```bash
# /initialize prints the exact command; e.g. a web + iOS app on Supabase:
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh web ios supabase roles
```

**4. Run the pipeline (any time):**

```
/feature <brief>
```

Only `CLAUDE.md` is written into your project — everything else lives in the plugin (referenced via
`${CLAUDE_PLUGIN_ROOT}`).

> **Optional — issue tracker for `/wayfinder`:** the business-analyst can use `/wayfinder` to plan
> large, multi-session efforts as decision tickets. It needs a tracker: run `/setup-matt-pocock-skills`
> and choose **github** (install & authenticate the `gh` CLI: `gh auth login`), **gitlab**, or
> **local markdown**. Linear isn't supported upstream. Skip this and the agent just uses `/grill-me`.

## The 11 agents

| Agent | Role |
|---|---|
| **business-analyst** | Raw brief → solution-agnostic business-requirements doc. Interviews you on blocking gaps. |
| **product-manager** | Business requirements → product spec (MoSCoW scope, v1 vs deferred, Gherkin AC). Answers "what," never "how." |
| **architect** | Product spec → technical decisions + owner-tagged build tasks (`owner: frontend\|ios\|flutter\|backend`). |
| **designer** | Architecture → `design.md`, a platform-aware design contract the client agents implement to. Runs only for UI initiatives. |
| **frontend** | Web client tasks (`owner: frontend`). |
| **ios** | Native iOS / SwiftUI tasks (`owner: ios`). |
| **flutter** | Cross-platform Flutter tasks (`owner: flutter`). |
| **backend** | Server/API/data tasks (`owner: backend`) — adapts to the one backend platform in §5. |
| **code-reviewer** | Reviews for clean / SOLID / DRY / YAGNI code that stays SIMPLE. Findings only. |
| **qa-tester** | Browser-tests against the Gherkin AC via the Playwright MCP. |
| **api-tester** | Exercises endpoints — scenarios, error handling, validation, auth. |

The pipeline itself is the **`/feature`** skill (main thread) — it assigns the slug, invokes each agent
in order, runs the **present** client agents + backend in parallel, consolidates the review, routes
fixes, loops, and stops at the human gates. (No separate conductor agent.)

## Flow

```
business-analyst ─[GATE]─▶ product-manager ─[GATE]─▶ architect ─▶ designer ─[GATE, if UI]─▶
   frontend / ios / flutter + backend (only the platforms in §5, parallel) ─▶ completion-report
      ─▶ code-reviewer + qa-tester + api-tester (parallel)
         ─▶ /feature consolidates review, routes fixes ─▶ the tagged build agent
            ─▶ loop ≤ 3 rounds, then report to the user
```

- **Human gates**: after business-analyst, after product-manager, and after designer (UI only).
- **Large scope auto-phases**: at intake `/feature` sizes up the brief on its own — if it's too big for
  one pass (e.g. a new project from scratch), it proposes an ordered set of shippable **phases**
  (`<project>-phase-N-<name>`), gets your approval, then runs the whole flow once per phase. You don't
  have to ask for this; routine features stay a single phase.
- **Backward handoffs** expected when upstream is wrong/ambiguous (architect → PM → BA; designer → PM).
- **Escalate-on-ambiguity**: downstream agents stop and ask rather than guess.
- **Worktree isolation**: `/feature` runs every initiative in its own git worktree off `develop` and
  merges it back automatically once it ships green — safe to run more than one `/feature` session on
  this repo at a time (`CLAUDE.md §9`).

## Stack skills

`skills.manifest.json` maps each stack to its build skills — **declared, not vendored**. Backend keys are
mutually exclusive; frontend keys coexist.

| Key | Agent | Skill(s) | Source |
|---|---|---|---|
| `web` | frontend | `/tailwind-design-system`, `/accessibility`, ReUI MCP + skills | wshobson/agents, addyosmani/web-quality-skills, mcp.reui.io |
| `ios` | ios | `swiftui-expert` | AvdLee/SwiftUI-Agent-Skill (plugin) |
| `flutter` | flutter | official `flutter/skills` suite | flutter/skills (20K+/skill) |
| `.net` | backend | `/dotnet-clean-arch` | i4mjad/dotnet-clean-arch-skill |
| `supabase` | backend | `/supabase`, `/supabase-postgres-best-practices` | supabase/agent-skills (official) |
| `firebase` | backend | official `firebase/*` suite | firebase/agent-skills (official) |

## Role skills

Always-on per pipeline agent (the `roles` section):

| Agent | Role skill | Source |
|---|---|---|
| business-analyst | `/grill-me`, `/wayfinder`¹ | mattpocock/skills (454K) |
| product-manager | `/to-prd`, `/to-issues` | mattpocock/skills |
| architect | `/architecture-designer` | jeffallan/claude-skills |
| designer | `/design-taste-frontend`, `/high-end-visual-design`, `/refactoring-ui-skills`, figma, Mobbin MCP | leonxlnx/taste-skill (217K), plugins/MCP |
| code-reviewer | `/ponytail-review`, `/ponytail-audit`, `/code-review-graph:review-delta` | plugins |
| qa-tester | Playwright MCP | `playwright` plugin |
| api-tester | `/api-testing` | secondsky/claude-skills |

¹ `/wayfinder` is optional, for efforts too big for one session. It needs an issue tracker — run
`/setup-matt-pocock-skills` and pick **github** (via the `gh` CLI, authenticated with `gh auth login`),
**gitlab**, or **local markdown**. There is no Linear tracker upstream. Without a tracker configured,
the business-analyst stays on `/grill-me`.

## Bootstrap

Install exactly what a project's shape needs:

```bash
# a web + iOS app on Supabase, plus every role skill:
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh web ios supabase roles
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh roles         # all role skills
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh --dry-run web # preview commands
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh              # list every key
```

**Update installed skills** from their upstreams (they track default branches, so this pulls the
latest) with the same keys plus `--update`:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh --update roles          # refresh every role skill
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh --update web ios roles  # refresh a whole project's set
```

Each agent invokes its skill **if present** — skip an install and the agent falls back to its own
prompt, so nothing breaks. `bootstrap.sh` reports any failed install explicitly (exit code 1 with a
summary) so a fallback never happens silently.

**Picking up new manifest entries** (an existing project that scaffolded before a skill was added to
`skills.manifest.json`): run `claude plugin update cc-setup@cc-setup` to pull the updated manifest, then
re-run the **plain** (non-`--update`) form for the affected key, e.g. `bootstrap.sh web` — it installs
whatever is new and safely re-runs whatever you already have. Use the plain form, not `--update`, for
this: `--update` assumes every `plugin`-kind entry under that key is already installed (it runs
`claude plugin update` instead of `install`), which fails on an entry that's newly added.

> **Supply-chain note:** the manifest's skill refs point at third-party repos and track their default
> branches — they are not version-pinned (the installers don't support commit pins). Review what you
> install; an upstream rename or deletion surfaces as an explicit bootstrap failure.

## What's in the plugin

```
.claude-plugin/{marketplace,plugin}.json   # marketplace + plugin manifests
agents/*.md                                # the 11 specialist agents (auto-discovered)
skills/feature/SKILL.md                    # the /feature pipeline orchestrator
commands/initialize.md                     # the /initialize project scaffolder
hooks/                                     # PreToolUse guard enforcing the write boundaries
templates/CLAUDE.md                        # the starter governance /initialize writes
skills.manifest.json                       # stack + role → skills map
scripts/bootstrap.sh                       # installs the skills your project needs
scripts/validate.sh                        # the plugin's own consistency checks (run by CI)
docs/ORCHESTRATION.md · docs/_templates/   # pipeline reference + artifact templates
```

**Enforced boundaries:** the reviewer agents (code-reviewer, qa-tester, api-tester) declare read-only
`tools:`, and a PreToolUse hook blocks any subagent writing `review.md`, reviewers writing files, and
spec/design agents writing app code — the pipeline's rules are mechanical, not just prompts.

## Local development / dogfooding

```bash
claude plugin marketplace add /path/to/cc-setup
claude plugin install cc-setup@cc-setup
```
