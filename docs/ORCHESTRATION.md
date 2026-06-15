# Orchestration — the agent pipeline

How the agent team runs. The **conductor** drives it; you are the approval gate. See `CLAUDE.md`
for the full governance and `.claude/agents/` for each agent's contract.

## Pipeline

```
            ┌──── HUMAN GATE ────┐      ┌──── HUMAN GATE ────┐
business-analyst ──▶ product-manager ──▶ architect ──▶ frontend ┐
   (interviews you)     (Gherkin AC)     (owner-tagged tasks)   ├─▶ completion-report.md
                                                       backend  ┘        │
                                                                         ▼
   conductor consolidates → review.md   ◀── code-reviewer ‖ qa-tester ‖ api-tester
                                                                         │
                          routed fixes ──▶ frontend / backend ──▶ re-review
                                                                         │
                              loop ≤ 3 rounds, then conductor reports to you
```

## Who hands to whom

| From | To | Gate | Carries |
|---|---|---|---|
| business-analyst | product-manager | **HUMAN** | business-requirements.md (approved) |
| product-manager | architect | **HUMAN** | product-spec.md (approved) |
| architect | frontend + backend | auto | spec.md + owner-tagged tasks |
| frontend, backend | reviewers | auto | completion-report.md |
| reviewers | conductor | auto | findings (owner + severity tagged) |
| conductor | frontend / backend | auto | routed fixes (+ the AC each maps to) |
| **backward:** architect → PM, PM → BA, reviewer → FE/BE | — | auto | the ambiguity/defect |
| **escalation:** any agent → user | **HUMAN** | — | a decision needing confirmation, not a guess |

## Artifact paths (per initiative `<slug>`)

| Stage | Artifact |
|---|---|
| Requirements | `docs/requirements/<slug>-business-requirements.md` |
| Product | `docs/product/<slug>-product-spec.md` |
| Architecture | `docs/architecture/<slug>/spec.md` + `tasks/NN-*.md` |
| Build | `docs/reports/<slug>/completion-report.md` (FE + BE owned sections) |
| Verify | `docs/reports/<slug>/review.md` (conductor-written) |

Templates for each live in `docs/_templates/`. The `<slug>` is assigned by the conductor at intake
and is the traceability key.

## Rules that are easy to forget

- **Two human gates only** (BA→PM, PM→architect). Everything else is automatic — except escalations.
- **Escalate, don't assume.** When a decision needs confirmation, stop and ask the user.
- **Backward handoffs are normal**, not failures — push ambiguity back to where it belongs.
- **Loop cap = 3 rounds**, then report to the user even if not green.
- **Owned sections / single writer:** FE and BE each own one section of the completion report; the
  conductor is the sole writer of `review.md`.
- **SIMPLE wins.** Over-engineering to satisfy a principle is a review finding, not a virtue.

## Starting an initiative

`@conductor` with the brief (e.g. a `thoughts.md` seed file). It assigns a slug, runs the
business-analyst (which interviews you), and stops at the first gate.
