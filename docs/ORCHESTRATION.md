# Orchestration — the agent pipeline

How the agent team runs. The **`/feature`** skill drives it (run by the main thread — there is no
conductor agent); you are the approval gate. See `CLAUDE.md` for the full governance and
the plugin's `agents/` for each agent's contract.

## Pipeline

```
  ┌──── HUMAN GATE (new project) ────┐
  bootstrap interview → fills CLAUDE.md §4/§5 ──▶ (skipped if already configured)
        ┌── GATE ──┐   ┌── GATE ──┐              ┌── GATE, if UI ──┐
business-analyst ─▶ product-manager ─▶ architect ─▶ designer ─▶ frontend ┐
   (interviews)       (Gherkin AC)   (owner tags)  (design.md)  ios      │
                                                                flutter  ├─▶ completion-report.md
                                                                backend  ┘        │
                                                                                  ▼
   /feature consolidates → review.md    ◀── code-reviewer ‖ qa-tester ‖ api-tester
                                                                                  │
              routed fixes ──▶ frontend / ios / flutter / backend ──▶ re-review
                                                                                  │
                              loop ≤ 3 rounds, then /feature reports to you
```

Only the client agents whose platform is set in CLAUDE.md §5 run (web→frontend, iOS→ios,
Flutter→flutter); `backend` adapts to the one backend platform. `designer` runs only for UI initiatives.

## Who hands to whom

| From | To | Gate | Carries |
|---|---|---|---|
| bootstrap interview (new project) | pipeline | **HUMAN** | filled CLAUDE.md §4/§5 (domain + stack), approved |
| business-analyst | product-manager | **HUMAN** | business-requirements.md (approved) |
| product-manager | architect | **HUMAN** | product-spec.md (approved) |
| architect | designer (if UI) | auto | spec.md + owner-tagged tasks |
| designer | build agents | **HUMAN** | design.md (approved) — UI initiatives only |
| architect / designer | frontend·ios·flutter + backend (present) | auto | spec + tasks + design.md |
| build agents | reviewers | auto | completion-report.md |
| reviewers | `/feature` | auto | findings (owner + severity tagged) |
| `/feature` | frontend / ios / flutter / backend | auto | routed fixes (+ the AC each maps to) |
| **backward:** architect → PM, designer → PM, PM → BA, reviewer → build agent | — | auto | the ambiguity/defect |
| **escalation:** any agent → user | **HUMAN** | — | a decision needing confirmation, not a guess |

## Artifact paths (per initiative `<slug>`)

| Stage | Artifact |
|---|---|
| Requirements | `docs/requirements/<slug>-business-requirements.md` |
| Product | `docs/product/<slug>-product-spec.md` |
| Architecture | `docs/architecture/<slug>/spec.md` + `tasks/NN-*.md` |
| Design | `docs/design/<slug>/design.md` (UI initiatives) |
| Build | `docs/reports/<slug>/completion-report.md` (Web/iOS/Flutter/Backend owned sections) |
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
