# cc-setup

A reusable **Claude Code plugin**: a **requirements → design → build → verify** agent team plus a
stack-aware skill set. Eleven specialist agents run a single pipeline, orchestrated by the **`/feature`**
skill, that takes a raw brief all the way to reviewed, verified code — stopping at human approval gates
along the way. The build agents are **platform-scoped**, so a web-only app and a web + iOS + Flutter app
each get exactly the agents they need.

Install it once and it's available in **every** project — no copy-paste, auto-updated via
`claude plugin update`.

## Install

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
- **Backward handoffs** expected when upstream is wrong/ambiguous (architect → PM → BA; designer → PM).
- **Escalate-on-ambiguity**: downstream agents stop and ask rather than guess.

## Stack skills

`skills.manifest.json` maps each stack to its build skills — **declared, not vendored**. Backend keys are
mutually exclusive; frontend keys coexist.

| Key | Agent | Skill(s) | Source |
|---|---|---|---|
| `web` | frontend | `/tailwind-design-system`, `/accessibility` | wshobson/agents, addyosmani/web-quality-skills |
| `ios` | ios | `swiftui-expert` | AvdLee/SwiftUI-Agent-Skill (plugin) |
| `flutter` | flutter | official `flutter/skills` suite | flutter/skills (20K+/skill) |
| `.net` | backend | `/dotnet-clean-arch` | i4mjad/dotnet-clean-arch-skill |
| `supabase` | backend | `/supabase`, `/supabase-postgres-best-practices` | supabase/agent-skills (official) |
| `firebase` | backend | official `firebase/*` suite | firebase/agent-skills (official) |

## Role skills

Always-on per pipeline agent (the `roles` section):

| Agent | Role skill | Source |
|---|---|---|
| business-analyst | `/grill-me` | mattpocock/skills (454K) |
| product-manager | `/to-prd`, `/to-issues` | mattpocock/skills |
| architect | `/architecture-designer` | jeffallan/claude-skills |
| designer | `/design-taste-frontend`, `/high-end-visual-design`, `/refactoring-ui-skills`, figma, Mobbin MCP | leonxlnx/taste-skill (217K), plugins/MCP |
| code-reviewer | `/ponytail-review`, `/ponytail-audit`, `/code-review-graph:review-delta` | plugins |
| qa-tester | Playwright MCP | `playwright` plugin |
| api-tester | `/api-testing` | secondsky/claude-skills |

## Bootstrap

Install exactly what a project's shape needs:

```bash
# a web + iOS app on Supabase, plus every role skill:
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh web ios supabase roles
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh roles         # all role skills
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh --dry-run web # preview commands
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh              # list every key
```

Each agent invokes its skill **if present** — skip an install and the agent falls back to its own
prompt, so nothing breaks.

## What's in the plugin

```
.claude-plugin/{marketplace,plugin}.json   # marketplace + plugin manifests
agents/*.md                                # the 11 specialist agents (auto-discovered)
skills/feature/SKILL.md                    # the /feature pipeline orchestrator
commands/initialize.md                           # the /initialize project scaffolder
templates/CLAUDE.md                        # the starter governance /initialize writes
skills.manifest.json                       # stack + role → skills map
scripts/bootstrap.sh                       # installs the skills your project needs
docs/ORCHESTRATION.md · docs/_templates/   # pipeline reference + artifact templates
```

## Local development / dogfooding

```bash
claude plugin marketplace add /path/to/cc-setup
claude plugin install cc-setup@cc-setup
```
