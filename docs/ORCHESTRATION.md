# Orchestration — the agent pipeline

How the agent team runs. The **`/feature`** skill drives it (run by the main thread — there is no
conductor agent); you are the approval gate. See `CLAUDE.md` for the full governance and
`.claude/agents/` for each agent's contract.

## Pipeline

```
  ┌──── HUMAN GATE (new project) ────┐
  bootstrap interview → fills CLAUDE.md §4/§5 ──▶ (skipped if already configured)
            ┌──── HUMAN GATE ────┐      ┌──── HUMAN GATE ────┐
business-analyst ──▶ product-manager ──▶ architect ──▶ frontend ┐
   (interviews you)     (Gherkin AC)     (owner-tagged tasks)   ├─▶ completion-report.md
                                                       backend  ┘        │
                                                                         ▼
   /feature consolidates → review.md    ◀── code-reviewer ‖ qa-tester ‖ api-tester
                                                                         │
                          routed fixes ──▶ frontend / backend ──▶ re-review
                                                                         │
                              loop ≤ 3 rounds, then /feature reports to you
```

## Who hands to whom

| From | To | Gate | Carries |
|---|---|---|---|
| bootstrap interview (new project) | pipeline | **HUMAN** | filled CLAUDE.md §4/§5 (domain + stack), approved |
| business-analyst | product-manager | **HUMAN** | business-requirements.md (approved) |
| product-manager | architect | **HUMAN** | product-spec.md (approved) |
| architect | frontend + backend | auto | spec.md + owner-tagged tasks |
| frontend, backend | reviewers | auto | completion-report.md |
| reviewers | `/feature` | auto | findings (owner + severity tagged) |
| `/feature` | frontend / backend | auto | routed fixes (+ the AC each maps to) |
| **backward:** architect → PM, PM → BA, reviewer → FE/BE | — | auto | the ambiguity/defect |
| **escalation:** any agent → user | **HUMAN** | — | a decision needing confirmation, not a guess |

## Artifact paths (per initiative `<slug>`)

| Stage | Artifact |
|---|---|
| Requirements | `docs/requirements/<slug>-business-requirements.md` |
| Product | `docs/product/<slug>-product-spec.md` |
| Architecture | `docs/architecture/<slug>/spec.md` + `tasks/NN-*.md` |
| Build | `docs/reports/<slug>/completion-report.md` (FE + BE owned sections) |
| Verify | `docs/reports/<slug>/review.md` (`/feature`-written) |

Templates for each live in `docs/_templates/`. The `<slug>` is assigned by `/feature` at intake
and is the traceability key.

## Rules that are easy to forget

- **Bootstrap before anything** on a new project: if CLAUDE.md §4/§5 still hold `<PLACEHOLDER>`s,
  `/feature` interviews you to fill them and stops at a human gate. Never inherit domain/stack defaults
  from a prior project. Skipped once the project is configured.
- **Two pipeline human gates** (BA→PM, PM→architect). Everything else is automatic — except escalations.
- **Escalate, don't assume.** When a decision needs confirmation, stop and ask the user.
- **Backward handoffs are normal**, not failures — push ambiguity back to where it belongs.
- **Loop cap = 3 rounds**, then report to the user even if not green.
- **Owned sections / single writer:** FE and BE each own one section of the completion report;
  `/feature` is the sole writer of `review.md`.
- **SIMPLE wins.** Over-engineering to satisfy a principle is a review finding, not a virtue.

## Starting an initiative

`/feature <brief>` (the brief inline or a `thoughts.md` seed file). On a brand-new project it first
runs the **bootstrap interview** to fill CLAUDE.md §4/§5 (domain + stack) and stops for your approval;
on an already-configured project it skips that. Then it assigns a slug, runs the business-analyst
(which interviews you on requirements), and stops at the first pipeline gate.
