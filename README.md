# cc-setup

A reusable **Claude Code plugin**: a **requirements → build → verify** agent team plus a stack-aware
skill set. Eight specialist agents run a single pipeline, orchestrated by the **`/feature`** skill,
that takes a raw brief all the way to reviewed, verified code — stopping at human approval gates along
the way.

Install it once and it's available in **every** project — no copy-paste, auto-updated via
`claude plugin update`.

## Install

```bash
claude plugin marketplace add i4mjad/cc-setup
claude plugin install cc-setup@cc-setup
```

Then, in any project:

```
/init                 # scaffold: writes a starter CLAUDE.md, interviews you for domain + stack
/feature <brief>      # run the pipeline on an idea
```

`/init` is the only setup step — it drops a `CLAUDE.md` into the repo and fills its domain/stack
defaults by interview. Everything else (agents, the `/feature` skill, the skill manifest, bootstrap,
artifact templates) lives in the plugin and is referenced via `${CLAUDE_PLUGIN_ROOT}` — nothing is
copied into your project except that one `CLAUDE.md`.

## The 8 agents

| Agent | Role |
|---|---|
| **business-analyst** | Raw brief → solution-agnostic business-requirements doc. Interviews you on blocking gaps. |
| **product-manager** | Business requirements → product spec (MoSCoW scope, v1 vs deferred, user stories + Gherkin acceptance criteria). Answers "what," never "how." |
| **architect** | Product spec → technical decisions + owner-tagged build tasks. Escalates to you instead of inventing answers to real gaps. |
| **frontend** | Implements `owner:frontend` tasks (UI/client). Invokes the SwiftUI/Flutter/web stack skill per CLAUDE.md §5. Runs in parallel with backend. |
| **backend** | Implements `owner:backend` tasks (server/API/data). Invokes `/dotnet-clean-arch` for .NET backends. Runs in parallel with frontend. |
| **code-reviewer** | Reviews for clean / SOLID / DRY / YAGNI code that stays SIMPLE. Findings only — does not rewrite. |
| **qa-tester** | Browser-tests against the Gherkin acceptance criteria, scenario by scenario. |
| **api-tester** | Exercises endpoints — scenarios, error handling, validation, auth. |

The pipeline itself is the **`/feature`** skill, run by the main thread — it assigns the slug, invokes
each agent in order, parallelizes build and review, consolidates the review, routes fixes, loops, and
stops at the human gates. (There is no separate conductor agent.)

## Flow

```
business-analyst ──[HUMAN GATE]──▶ product-manager ──[HUMAN GATE]──▶ architect
   ──▶ frontend + backend (parallel) ──▶ completion-report
      ──▶ code-reviewer + qa-tester + api-tester (parallel)
         ──▶ /feature consolidates review, routes fixes ──▶ frontend / backend
            ──▶ loop ≤ 3 rounds, then report to the user
```

- **Two human gates**: after business-analyst and after product-manager — `/feature` stops for your approval.
- **Backward handoffs** are expected when upstream work is wrong/ambiguous (architect → PM → BA).
- **Escalate-on-ambiguity**: downstream agents stop and ask rather than fill a real gap with a guess.

## Stack skills

`skills.manifest.json` maps each stack (CLAUDE.md §5) to the specialist skills that help build it —
**declared, not vendored**, so they stay in sync with upstream and only the ones your stack needs get
installed:

| Stack key | Skill | Source |
|---|---|---|
| `.net` | `/dotnet-clean-arch` | `i4mjad/dotnet-clean-arch-skill` (`npx skills add`) |
| `ios-swiftui` | `swiftui-expert` | `AvdLee/SwiftUI-Agent-Skill` (plugin) |
| `web` | `/ui-ux-pro-max` | `nextlevelbuilder/ui-ux-pro-max-skill` (plugin) |
| `flutter` | `/flutter-dart-code-review` | _TODO — add a public source_ |

Install the ones a project needs (the paths resolve inside the plugin):

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh .net            # or: ios-swiftui web flutter …
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh --dry-run .net  # preview the install commands
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh                 # list available stack keys
```

The `frontend`/`backend` agents then invoke the matching skill automatically when CLAUDE.md §5 sets
that stack.

## What's in the plugin

```
.claude-plugin/
  marketplace.json          # marketplace entry (this repo is its own marketplace)
  plugin.json               # plugin manifest
agents/*.md                 # the 8 specialist agents (auto-discovered)
skills/feature/SKILL.md     # the /feature pipeline orchestrator (auto-discovered)
commands/init.md            # the /init project scaffolder (auto-discovered)
templates/CLAUDE.md         # the starter governance /init writes into a project
skills.manifest.json        # stack → skills map
scripts/bootstrap.sh        # installs the skills matching your stack
docs/
  ORCHESTRATION.md          # pipeline + handoff reference
  _templates/*.md           # the 6 artifact templates the agents write from
```

## Local development / dogfooding

To iterate on this plugin from a local checkout, add it as a marketplace by path:

```bash
claude plugin marketplace add /path/to/cc-setup
claude plugin install cc-setup@cc-setup
```
