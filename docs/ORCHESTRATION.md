# Orchestration — the agent pipeline

How the agent team runs. The **`/feature`** skill drives it (run by the main thread — there is no
conductor agent); you are the approval gate. See `CLAUDE.md` for the full governance and
the plugin's `agents/` for each agent's contract.

## Pipeline

```
  ┌──── HUMAN GATE (new project) ────┐
  bootstrap interview → fills CLAUDE.md §4/§5 ──▶ (skipped if already configured)
   ┌── GATE ──┐  ┌── GATE ──┐   ┌── GATE ──┐              ┌── GATE, if UI ──┐
discovery ─▶ business-analyst ─▶ product-manager ─▶ architect ─▶ designer ─▶ frontend ┐
(GO/PIVOT/KILL)  (interviews)      (Gherkin AC)    (owner tags)  (design.md)  ios     │
   │                                                                          flutter ├─▶ completion-report.md
   └── KILL ──▶ pipeline stops; /feature reports the verdict                  backend ┘        │
                                                                                               ▼
   /feature consolidates → review.md    ◀── code-reviewer ‖ qa-tester ‖ api-tester
                                                                                               │
              routed fixes ──▶ frontend / ios / flutter / backend ──▶ re-review
                                                                                               │
                              loop ≤ 3 rounds, then /feature reports to you
```

**Discovery gates the whole pipeline.** Every initiative starts there: it steelmans the idea, then
interrogates value → viability → usability → feasibility in that order and returns
**GO / PIVOT / KILL** with falsifiable kill criteria. On KILL the pipeline stops — nothing reaches the
business-analyst, and only you can overrule the verdict. On GO/PIVOT only the brief's **Handoff to BA**
section crosses the gate; the rest is your decision record.

Only the client agents whose platform is set in CLAUDE.md §5 run (web→frontend, iOS→ios,
Flutter→flutter); `backend` adapts to the one backend platform. `designer` runs only for UI initiatives.

**Large scope is phased by default.** After discovery, `/feature` sizes up what the v1 boundary left
without being asked; if it's too big for one pass (typically a new project), it splits the work into an
ordered set of shippable **phases** (`<project>-phase-N-<name>`), gets your approval at a **phase-plan
gate**, then runs the rest of the pipeline once per phase, shipping between them. A routine feature is
a single phase. **Discovery is not re-run per phase** — a phase is an increment of an already-validated
idea, not a new idea.

## Who hands to whom

| From | To | Gate | Carries |
|---|---|---|---|
| bootstrap interview (new project) | pipeline | **HUMAN** | filled CLAUDE.md §4/§5 (domain + stack), approved |
| discovery | business-analyst | **HUMAN** | `docs/discovery/<slug>.md` — GO/PIVOT approved; **Handoff to BA** section only |
| discovery | — (pipeline stops) | **HUMAN** | a KILL verdict; nothing is handed forward |
| business-analyst | product-manager | **HUMAN** | business-requirements.md (approved) |
| product-manager | architect | **HUMAN** | product-spec.md (approved) |
| architect | designer (if UI) | auto | spec.md + owner-tagged tasks |
| designer | build agents | **HUMAN** | design.md (approved) — UI initiatives only |
| architect / designer | frontend·ios·flutter + backend (present) | auto | spec + tasks + design.md |
| build agents | reviewers | auto | completion-report.md |
| reviewers | `/feature` | auto | findings (owner + severity tagged) |
| `/feature` | frontend / ios / flutter / backend | auto | routed fixes (+ the AC each maps to) |
| **backward:** architect → PM, designer → PM, PM → BA, BA → discovery, reviewer → build agent | — | auto | the ambiguity/defect |
| **escalation:** any agent → user | **HUMAN** | — | a decision needing confirmation, not a guess |

## Artifact paths (per initiative `<slug>`)

| Stage | Artifact |
|---|---|
| Discovery | `docs/discovery/<slug>.md` |
| Requirements | `docs/requirements/<slug>-business-requirements.md` |
| Product | `docs/product/<slug>-product-spec.md` |
| Architecture | `docs/architecture/<slug>/spec.md` + `tasks/NN-*.md` |
| Design | `docs/design/<slug>/design.md` (UI initiatives) |
| Build | `docs/reports/<slug>/completion-report.md` (Web/iOS/Flutter/Backend owned sections) |
| Verify | `docs/reports/<slug>/review.md` (`/feature`-written) |

Templates for each live in `docs/_templates/` (including `design.template.md`). The `<slug>` is
assigned by `/feature` at intake and is the traceability key.

## Rules that are easy to forget

- **Bootstrap before anything** on a new project: if CLAUDE.md §4/§5 still hold `<PLACEHOLDER>`s,
  `/feature` interviews you to fill them and stops at a human gate. Never inherit domain/stack defaults
  from a prior project. Skipped once the project is configured.
- **Four pipeline human gates** (discovery→BA, BA→PM, PM→architect, designer→build for UI
  initiatives). Everything else is automatic — except escalations.
- **A KILL is a real stop.** Discovery's job is to be the friction, and a fast honest no is its most
  valuable output. `/feature` may not downgrade a KILL to "maybe later" — only you can overrule it.
- **Escalate, don't assume.** When a decision needs confirmation, stop and ask the user.
- **Backward handoffs are normal**, not failures — push ambiguity back to where it belongs.
- **Green = zero open blockers and majors.** Minors may ship but are listed in the report.
- **Loop cap = 3 rounds**, then report to the user even if not green — leading with an explicit
  NOT SHIPPABLE status if blockers/majors remain.
- **Owned sections / single writer:** each dispatched build agent (frontend/ios/flutter/backend) owns
  one section of the completion report, which `/feature` pre-creates; `/feature` is the sole writer of
  `review.md`.
- **SIMPLE wins.** Over-engineering to satisfy a principle is a review finding, not a virtue.
- **Worktree isolation is automatic, but `CLAUDE.md` §9 outranks it.** By default `/feature` creates
  `.worktrees/<slug>` off `develop` at Setup and merges it back (`--no-ff`, conflicts resolved) once the
  initiative ships green, then removes the worktree and branch. This is what makes concurrent `/feature`
  sessions on the same repo safe. A `NOT SHIPPABLE` result at the loop cap skips the merge and leaves
  the worktree for the next session to resume from.
  **That default applies only where §9 hasn't replaced it.** §9 is the project's git policy, not a copy
  of the plugin's — a project that uses a different granularity (one worktree per edit), base branch,
  merge target, or requires review before merge writes that in §9, and `/feature` follows §9 instead.
  If §9 and this default conflict, §9 wins; if they can't be reconciled, `/feature` asks rather than
  picking.

## Enforcement & known limits

- **Read-only reviewers are enforced, not just prompted:** code-reviewer, qa-tester, and api-tester
  declare restricted `tools:` (no Write/Edit), and the plugin ships a PreToolUse hook
  (`hooks/guard-writes.sh`) that blocks any subagent writing `review.md`, any reviewer writing files,
  and spec/design agents writing under `apps/`/`services/`.
- **Native-client verification is test-based, not driven:** qa-tester reaches only the browser. iOS
  and Flutter AC are verified by the build agents' own XCTest / widget-test suites, whose results are
  required evidence in the completion report. A simulator-driving mobile-qa agent is a possible future
  addition.
- **Per-role models:** agents inherit the session model by default. If you want cheaper reviewers or a
  stronger architect, add a `model:` field to the agent frontmatter — deliberately not preset here.

## Starting an initiative

`/feature <brief>` (the brief inline or a `thoughts.md` seed file). On a brand-new project it first
runs the **bootstrap interview** to fill CLAUDE.md §4/§5 (domain + stack) and stops for your approval;
on an already-configured project it skips that. Then it assigns a slug, creates that initiative's git
worktree (`.worktrees/<slug>` off `develop`), runs **discovery** (which interrogates the idea and
returns a GO/PIVOT/KILL verdict), and stops at the first pipeline gate. Expect discovery to push back —
that is the point of it.
