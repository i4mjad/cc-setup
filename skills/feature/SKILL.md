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
- **Isolate in a worktree.** `git worktree add .worktrees/<slug> -b feature/<slug> develop` (fall back
  to the current branch if `develop` doesn't exist); ensure `.worktrees/` is gitignored (append if
  missing). Do every stage below — every dispatched agent, every commit — inside that worktree. This is
  what makes a concurrent `/feature` session on this repo safe (CLAUDE.md §9).
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
2. **Intake & scope check.** Confirm the `<slug>` derived at Setup; all artifacts are keyed by it.
   **Assess scope by default — the user does not have to ask for this.** If the brief is too big to
   carry cleanly through one pipeline pass — several loosely-coupled capability areas, or more than a
   single coherent build's worth of work (common when standing up a **new project** from scratch) —
   split it yourself into an ordered set of **phases**, each a shippable increment with its own
   `<project>-phase-N-<name>` slug and a one-line "delivers …". Propose that phase list to the user
   and get approval (**phase-plan gate**), then run the full pipeline (steps 3–10) once per phase in
   order, shipping between phases; a phase may reveal work that reshapes later phases, so re-confirm
   the remaining list if it changes. A normal-sized initiative is **one phase** — skip this and carry
   on. Don't over-split: phases are for genuinely large scope, not routine features.
3. **Requirements → business-requirements.md.** Dispatch **business-analyst** with the brief. It
   interviews the user (relay its Open Questions) and writes
   `docs/requirements/<slug>-business-requirements.md`. **Gate.**
4. **Product → product-spec.md.** On approval, dispatch **product-manager** →
   `docs/product/<slug>-product-spec.md` (MoSCoW scope, v1 vs deferred, user stories + Gherkin AC).
   **Gate.**
5. **Architecture → spec.md + tasks.** On approval, dispatch **architect** →
   `docs/architecture/<slug>/spec.md` + owner-tagged `tasks/NN-*.md` (each
   `owner: frontend|ios|flutter|backend`, using only the platforms in §5). If the architect escalates a
   decision, relay it and wait. No gate otherwise — but before proceeding, run a **coverage check**:
   every must-have AC in the product spec maps to at least one task, and every task's `owner:` names a
   platform actually present in §5. If either fails, re-dispatch the architect with the exact gaps —
   never fan out Build on a broken task graph.
6. **Design → design.md** *(only if the initiative has UI)*. Dispatch **designer** →
   `docs/design/<slug>/design.md` — the platform-aware design contract the client agents implement to.
   Relay Open Questions. **Gate.**
7. **Build (parallel).** First **pre-create** `docs/reports/<slug>/completion-report.md` from
   `${CLAUDE_PLUGIN_ROOT}/docs/_templates/completion-report.template.md` (scaffolding only — you author
   no content). Then dispatch **only the agents whose platform is in §5 AND that own ≥ 1 task** —
   **frontend** (web, `owner: frontend`), **ios** (`owner: ios`), **flutter** (`owner: flutter`),
   **backend** (`owner: backend`) — all in parallel (one message, multiple Agent calls). For a present
   platform with zero owned tasks, do **not** dispatch its agent; mark its report section
   "No tasks for this platform in this initiative — n/a" yourself. Each dispatched agent fills **only
   its owned section** of the shared report and invokes its stack skill per §5 (see the agent files).
   Confirm every dispatched agent's section is complete.
8. **Verify (parallel).** Dispatch **code-reviewer**, **qa-tester**, and **api-tester** in parallel
   against the completion report and the product spec's Gherkin AC. They **return findings to you** —
   **you** are the single writer of `docs/reports/<slug>/review.md` (sections: Code review / QA / API
   + a Routed-fixes list). Do not let reviewers write that file in parallel.
9. **Route & loop.** Route each open issue to its tagged owner (**frontend/ios/flutter/backend**) with
   the exact finding + the AC it maps to. After fixes, re-run only the relevant reviewers. **Green =
   zero open blocker and zero open major findings** — minors may ship but must be listed in the final
   report. Loop build→review→fix until green or **3 rounds**, then report even if not green.
10. **Report.** Summarize to the user: what shipped, what each verifier confirmed, unresolved issues,
   and the trace outcomes → AC → tasks → verification. If blockers or majors remain after the 3-round
   cap, the report must **open with an explicit `NOT SHIPPABLE` status** and list them first — never a
   neutral summary.
11. **Merge & cleanup** (only when green). `git checkout develop && git merge --no-ff feature/<slug>`.
   Resolve any conflicts before considering the initiative done — never drop a conflicting hunk or force
   one side to win without checking intent against both changes. On a clean merge, remove the worktree
   (`git worktree remove .worktrees/<slug>`) and delete the branch (`git branch -d feature/<slug>`). If
   the loop hit the 3-round cap and reported `NOT SHIPPABLE`, skip this — leave the worktree and branch
   in place for the next session to resume from.

## Handoffs
- Forward & gates per `CLAUDE.md` §2. You own the human gates: the bootstrap gate (new project only),
  the phase-plan gate (large scope only — step 2), and the three pipeline gates (after
  business-analyst, after product-manager, and after designer — UI initiatives only).
- Backward: if any agent reports the upstream artifact is wrong/ambiguous, route it backward
  (architect→product-manager, product-manager→business-analyst, designer→product-manager,
  reviewer→frontend/ios/flutter/backend) and re-run forward from there.
- Escalation: relay any agent's escalation to the user verbatim; never answer on their behalf.

## Rules of engagement
- Keep every artifact in `docs/…/<slug>/` and pass **paths**, not context blobs — each subagent reads
  `CLAUDE.md` and the referenced files itself.
- Skip stages cleanly when the spec says an area isn't involved (e.g. no backend tasks → don't
  dispatch the backend agent; mark its report section n/a per step 7).
- Commit discipline (CLAUDE.md §6): small, meaningful commits — one logical change each; the build
  agents commit as they go, you never squash them into one end-of-task commit.

## Definition of done
Every dispatched platform's completion-report section filled (absent/no-task platforms marked n/a);
`review.md` green — zero open blockers and majors — or the 3-round cap hit and reported as
NOT SHIPPABLE; every shipped piece traceable to a business outcome; if green, the worktree merged into
`develop` and cleaned up (step 11). Then hand the result to the user.
