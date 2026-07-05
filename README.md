# cc-setup

A reusable **Claude Code setup**: a **requirements → build → verify** agent team plus a curated,
stack-aware skill set. Eight specialist agents run a single pipeline, orchestrated by the **`/feature`**
skill, that takes a raw client brief all the way to reviewed, verified code — stopping at human
approval gates along the way.

Drop it into any project and start with `/feature <brief>`.

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

## What's in this repo

```
CLAUDE.md                       # genericized governance — fill the <PLACEHOLDER>s per project
.claude/agents/*.md             # the 8 specialist agents (project-agnostic)
.claude/skills/feature/SKILL.md # the /feature pipeline orchestrator (entry point)
skills.manifest.json            # stack → skills map
scripts/bootstrap.sh            # installs the skills matching your stack
docs/
  ORCHESTRATION.md              # pipeline + handoff reference
  _templates/*.md               # the 6 artifact templates the agents copy from
```

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

Install the ones a project needs:

```bash
bash scripts/bootstrap.sh .net            # or: ios-swiftui web flutter …
bash scripts/bootstrap.sh --dry-run .net  # preview the install commands
bash scripts/bootstrap.sh                 # list available stack keys
```

The `frontend`/`backend` agents then invoke the matching skill automatically when CLAUDE.md §5 sets
that stack.

## Reuse in a project

```bash
# from your project root
cp -R /path/to/cc-setup/.claude/agents  .claude/agents
cp -R /path/to/cc-setup/.claude/skills  .claude/skills
cp    /path/to/cc-setup/skills.manifest.json .
cp -R /path/to/cc-setup/scripts .
cp    /path/to/cc-setup/CLAUDE.md .            # then fill in the <PLACEHOLDER>s
mkdir -p docs && cp -R /path/to/cc-setup/docs/_templates docs/_templates
cp    /path/to/cc-setup/docs/ORCHESTRATION.md docs/
```

Then start the team with **`/feature <brief>`** (the brief inline or a `thoughts.md` seed). **On a new
project `/feature` interviews you first** to fill `CLAUDE.md` §4 (domain) and §5 (stack) — market,
audience, privacy/safety/compliance constraints, localization/RTL, and the web/mobile/backend/
automation/AI stack — and stops for your approval before any pipeline work. You can also fill those
`<PLACEHOLDER>`s by hand up front; if they're already filled, the bootstrap interview is skipped. Once
the stack is set, run `bash scripts/bootstrap.sh <stack-key…>` to install the matching skills.

### Per-project notes

- The agents read **every domain & stack default** (web/mobile/backend choices, market, audience,
  privacy/safety constraints, localization) from the project's `CLAUDE.md` — they never assume them and
  never inherit them from a prior project. The agent files themselves are project-agnostic.
- The agents write artifacts under `docs/` (requirements, product, architecture, reports) and copy
  from `docs/_templates/`. Those template files are generic and ready to use as-is.
