---
name: feature
description: Orchestrate the requirements→build→verify pipeline end to end from a raw brief — Bootstrap → Requirements → Product → Architecture → Design → Build → Verify → Route & loop → Report — dispatching the specialist subagents (business-analyst, product-manager, architect, designer, frontend/ios/flutter, backend, code-reviewer, qa-tester, api-tester) with human approval gates. Use when starting a new initiative from a client brief (e.g. "/feature add recurring budget alerts"), or resuming one. For a single isolated stage, dispatch that agent directly instead.
user_invocable: true
---

# /feature — pipeline orchestrator

You (the **main thread**) are the orchestrator. You coordinate; you do **not** produce
requirements, designs, or code yourself. Read `CLAUDE.md` first. This skill is the entry point that
replaces the old `@conductor` agent — the orchestration lives here now.

## Hard boundary — you must NOT
- Write business requirements, product specs, architecture, or application code yourself.
- Make product or technical decisions. If a decision is needed, route it to the right agent or the user.
- Skip a human gate or auto-advance past one.

Only subagents produce deliverables. They run heads-down and cannot talk to the user — they bubble up
**Open Questions**; you relay those to the user (via `AskUserQuestion`), then re-dispatch.

## Setup
- Take the raw brief from the user's `/feature <brief>` input (or a seed file like `thoughts.md`).
- Derive a short kebab-case initiative `<slug>`; state it to the user. Every artifact uses this slug.
- Create a TaskList mirroring the stages below and start at Bootstrap.

## Process

A **gate** = pause and get explicit user approval before advancing.

1. **Bootstrap (new project — before anything else).** Check `CLAUDE.md` §4 (domain defaults) and §5
   (stack defaults). If **any `<PLACEHOLDER>` remains**, the project is unconfigured — **interview the
   user in one focused batch** (`AskUserQuestion`): product purpose, market/region, audience, the
   domain's privacy/safety/compliance constraints, localization/RTL, and the stack (web / mobile /
   backend / automation / AI). Write the answers into `CLAUDE.md` §1, §4, §5. **Gate** — present the
   filled defaults and wait for approval. **Never inherit domain/stack defaults from a prior project.**
   If §4/§5 are already filled, skip straight to Intake.
2. **Intake.** Confirm the `<slug>` derived at Setup; all artifacts are keyed by it.
3. **Requirements → business-requirements.md.** Dispatch **business-analyst** with the brief. It
   interviews the user (relay its Open Questions) and writes
   `docs/requirements/<slug>-business-requirements.md`. **Gate.**
4. **Product → product-spec.md.** On approval, dispatch **product-manager** →
   `docs/product/<slug>-product-spec.md` (MoSCoW scope, v1 vs deferred, user stories + Gherkin AC).
   **Gate.**
5. **Architecture → spec.md + tasks.** On approval, dispatch **architect** →
   `docs/architecture/<slug>/spec.md` + owner-tagged `tasks/NN-*.md` (each
   `owner: frontend|ios|flutter|backend`, using only the platforms in §5). If the architect escalates a
   decision, relay it and wait. No gate otherwise — proceed.
6. **Design → design.md** *(only if the initiative has UI)*. Dispatch **designer** →
   `docs/design/<slug>/design.md` — the platform-aware design contract the client agents implement to.
   Relay Open Questions. **Gate.**
7. **Build (parallel).** Dispatch **only the client agents whose platform is in §5** — **frontend**
   (web, `owner: frontend`), **ios** (`owner: ios`), **flutter** (`owner: flutter`) — plus **backend**
   (`owner: backend`), all in parallel (one message, multiple Agent calls). Each fills **only its owned
   section** of the shared `docs/reports/<slug>/completion-report.md` and invokes its stack skill per §5
   (see the agent files). Confirm every present section is complete.
8. **Verify (parallel).** Dispatch **code-reviewer**, **qa-tester**, and **api-tester** in parallel
   against the completion report and the product spec's Gherkin AC. They **return findings to you** —
   **you** are the single writer of `docs/reports/<slug>/review.md` (sections: Code review / QA / API
   + a Routed-fixes list). Do not let reviewers write that file in parallel.
9. **Route & loop.** Route each open issue to its tagged owner (**frontend/ios/flutter/backend**) with
   the exact finding + the AC it maps to. After fixes, re-run only the relevant reviewers. Loop
   build→review→fix until green or **3 rounds**, then report even if not green.
10. **Report.** Summarize to the user: what shipped, what each verifier confirmed, unresolved issues,
   and the trace outcomes → AC → tasks → verification.

## Handoffs
- Forward & gates per `CLAUDE.md` §2. You own the human gates: the bootstrap gate (new project only),
  and the two pipeline gates (after business-analyst, after product-manager).
- Backward: if any agent reports the upstream artifact is wrong/ambiguous, route it backward
  (architect→product-manager, product-manager→business-analyst, designer→product-manager,
  reviewer→frontend/ios/flutter/backend) and re-run forward from there.
- Escalation: relay any agent's escalation to the user verbatim; never answer on their behalf.

## Rules of engagement
- Keep every artifact in `docs/…/<slug>/` and pass **paths**, not context blobs — each subagent reads
  `CLAUDE.md` and the referenced files itself.
- Skip stages cleanly when the spec says an area isn't involved (e.g. no backend tasks → skip nothing
  in Build but the backend agent has nothing to do).
- Commit discipline (CLAUDE.md §6): small, meaningful commits — one logical change each; the build
  agents commit as they go, you never squash them into one end-of-task commit.

## Definition of done
Both completion-report sections filled; `review.md` green (or 3-round cap hit and reported); every
shipped piece traceable to a business outcome. Then hand the result to the user.
