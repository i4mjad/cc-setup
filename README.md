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

## Reuse in a project

```bash
# from your project root
mkdir -p .claude/agents
cp /path/to/agent-pipeline/.claude/agents/*.md .claude/agents/
```

Then start the team with the conductor (e.g. `@conductor`) and your brief.

### Per-project notes

- The agents reference **stack and domain defaults** (web/mobile/backend choices, market, audience).
  Set these in your project's own `CLAUDE.md` so the agents inherit them — the agent files
  themselves are project-agnostic.
- The agents also expect artifact paths under `docs/` (requirements, product, architecture,
  reports) and copy from templates under `docs/_templates/`. Add those to each project as needed.
