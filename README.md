# agent-pipeline

A reusable **requirements → build → verify** agent team for Claude Code. Nine agents run a
single pipeline, driven by the **conductor**, that takes a raw client brief all the way to
reviewed, verified code — stopping at human approval gates along the way.

Drop these into any project's `.claude/agents/` and the team is available immediately.

## The 9 agents

| Agent | Role |
|---|---|
| **conductor** | Orchestrates the whole pipeline — assigns the slug, invokes each agent in order, parallelizes build and review, routes fixes, loops, and stops at the human gates. Never does requirements, design, or coding itself. |
| **business-analyst** | Raw brief → solution-agnostic business-requirements doc. Interviews you on blocking gaps. |
| **product-manager** | Business requirements → product spec (MoSCoW scope, v1 vs deferred, user stories + Gherkin acceptance criteria). Answers "what," never "how." |
| **architect** | Product spec → technical decisions + owner-tagged build tasks. Escalates to you instead of inventing answers to real gaps. |
| **frontend** | Implements `owner:frontend` tasks (UI/client). Runs in parallel with backend. |
| **backend** | Implements `owner:backend` tasks (server/API/data). Runs in parallel with frontend. |
| **code-reviewer** | Reviews for clean / SOLID / DRY / YAGNI code that stays SIMPLE. Findings only — does not rewrite. |
| **qa-tester** | Browser-tests against the Gherkin acceptance criteria, scenario by scenario. |
| **api-tester** | Exercises endpoints — scenarios, error handling, validation, auth. |

## Flow

```
business-analyst ──[HUMAN GATE]──▶ product-manager ──[HUMAN GATE]──▶ architect
   ──▶ frontend + backend (parallel) ──▶ completion-report
      ──▶ code-reviewer + qa-tester + api-tester (parallel)
         ──▶ conductor consolidates review, routes fixes ──▶ frontend / backend
            ──▶ loop ≤ 3 rounds, then report to the user
```

- **Two human gates**: after business-analyst and after product-manager — the conductor stops for your approval.
- **Backward handoffs** are expected when upstream work is wrong/ambiguous (architect → PM → BA).
- **Escalate-on-ambiguity**: downstream agents stop and ask rather than fill a real gap with a guess.

## What's in this repo

```
CLAUDE.md                  # genericized governance — fill the <PLACEHOLDER>s per project
.claude/agents/*.md        # the 9 agents (project-agnostic)
docs/
  ORCHESTRATION.md         # pipeline + handoff reference
  _templates/*.md          # the 6 artifact templates the agents copy from
```

## Reuse in a project

```bash
# from your project root
cp -R /path/to/agent-pipeline/.claude/agents .claude/agents
cp    /path/to/agent-pipeline/CLAUDE.md .            # then fill in the <PLACEHOLDER>s
mkdir -p docs && cp -R /path/to/agent-pipeline/docs/_templates docs/_templates
cp    /path/to/agent-pipeline/docs/ORCHESTRATION.md docs/
```

Then start the team with the conductor (e.g. `@conductor`) and your brief. **On a new project the
conductor interviews you first** to fill `CLAUDE.md` §4 (domain) and §5 (stack) — market, audience,
privacy/safety/compliance constraints, localization/RTL, and the web/mobile/backend/automation/AI
stack — and stops for your approval before any pipeline work. You can also fill those `<PLACEHOLDER>`s
by hand up front; if they're already filled, the bootstrap interview is skipped.

### Per-project notes

- The agents read **every domain & stack default** (web/mobile/backend choices, market, audience,
  privacy/safety constraints, localization) from the project's `CLAUDE.md` — they never assume them and
  never inherit them from a prior project. The agent files themselves are project-agnostic.
- The agents write artifacts under `docs/` (requirements, product, architecture, reports) and copy
  from `docs/_templates/`. Those template files are generic and ready to use as-is.
