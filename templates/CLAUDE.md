# <PROJECT_NAME> — Project Memory

This file governs the whole workspace. Every agent from the **cc-setup plugin** reads it
automatically. Read it before acting.

> **Reuse note:** this is the genericized governance for the agent pipeline. Replace every
> `<PLACEHOLDER>` below with your project's specifics before starting an initiative. The agent
> files themselves are project-agnostic and read their defaults from here.

## 1. Purpose

<PROJECT_NAME> is <ONE_LINE_PRODUCT_DESCRIPTION>. <STATE_WHETHER_GREENFIELD_OR_EXISTING — e.g. "The
repo is currently greenfield — no apps exist yet" or "Apps live under `apps/` and `services/`">.

## 2. The agent team & pipeline

13 specialist agents run a discovery → build → verify pipeline, orchestrated by the
**`/feature`** skill (run by the main thread — there is no conductor agent). The **build agents are
platform-scoped**: `frontend` (web), `ios`, `flutter`, and an adaptive `backend` — `/feature`
dispatches only the ones whose platform is set in §5.

```
  ┌ codex gate ┐ ┌ codex gate ┐  ┌ codex gate ┐          ┌ codex gate, if UI ┐
discovery ▶ business-analyst ▶ product-manager ▶ architect ▶ designer ▶ frontend ┐
   │                                                                   ios       │
   │                                                                   flutter   ├─▶ completion-report
   └── KILL ─▶ pipeline stops (yours to overrule)                      backend   ┘        │
                                        ┌── code-reviewer ──┐                            │
                                        ├── qa-tester ──────┤◀───────────────────────────┘
                                        ├── api-tester ─────┤
                                        └── codex-reviewer ─┘
                                                │ (findings → /feature → review.md)
                                                ▼
                                 routed fixes ─▶ frontend / ios / flutter / backend
                                                │
                                     auto-loop ≤ 3 rounds, then report to user

  codex gate = Codex reviews the artifact, codex-reviewer challenges it, pipeline advances on approve.
  Only two gates still stop for you: the bootstrap interview and the phase plan.
```

**Discovery runs first, on every initiative.** It challenges the idea against value → viability →
usability → feasibility risk (in that order) and returns **GO / PIVOT / KILL** with falsifiable kill
criteria. A KILL stops the pipeline — only you can overrule it. On GO/PIVOT, only the brief's
**Handoff to BA** section crosses the gate, and its out-of-scope cuts are binding on everything
downstream.

- **`/feature`** orchestrates (the main thread, not a subagent): assigns the initiative `<slug>`,
  invokes each agent in order, runs the **present** client agents (frontend/ios/flutter) + backend in
  parallel and the four reviewers in parallel, writes the consolidated `review.md` and `gates.md`,
  routes fixes, loops, and stops only at the two human gates. It never does requirements, design, or
  coding itself. Start an initiative with `/feature <brief>`.

### Handoff rules

| Handoff | Type |
|---|---|
| bootstrap intake interview → pipeline (new project only) | **HUMAN GATE** — stop for user approval of the filled §4/§5 defaults |
| discovery → business-analyst | **CODEX GATE** on GO/PIVOT — advances on approve, no wait. A **KILL stops the pipeline** and is yours alone to overrule; Codex never sees it |
| scope check → phase plan (large scope only) | **HUMAN GATE** — stop for approval of the proposed phases (auto-proposed, not user-requested) |
| business-analyst → product-manager | **CODEX GATE** — advances on approve, no wait |
| product-manager → architect | **CODEX GATE** — advances on approve, no wait |
| architect → designer (only if the initiative has UI) | automatic |
| designer → build agents | **CODEX GATE** (UI initiatives only) — advances on approve, no wait |
| architect / designer → frontend·ios·flutter + backend (present platforms) | automatic |
| build agents → reviewers | automatic |
| reviewers → build agents (routed fixes) | automatic, via `/feature` |
| any codex gate → you | **HUMAN GATE**, but only on three conditions: Codex is unreachable, Codex held a finding against the peer challenge, or three rounds failed to clear it |

**Codex gates replace your four spec approvals.** At each one, `/feature` dispatches **codex-reviewer**:
Codex (GPT) reviews the artifact independently, then codex-reviewer challenges every finding against the
document and rebuts what does not hold. One rebuttal round-trip, then:

1. **Approve** → you get a one-line notice and the pipeline advances. Nothing waits on you.
2. **Needs attention** → the authoring agent gets the surviving findings and rewrites. Max 3 rounds.
3. **Codex held its position** against the challenge → both arguments come to you verbatim. You decide;
   neither model wins by default.
4. **Codex unreachable** → that gate becomes a human gate. The pipeline never advances unreviewed.

The full exchange — findings, disputes, concessions — is logged to `docs/reviews/<slug>/gates.md`. That
log is the audit trail that replaces your signature, so read it when you want to know why something passed.

**Backward handoffs** are allowed and expected when work upstream is wrong/ambiguous:
architect → product-manager, designer → product-manager, product-manager → business-analyst,
business-analyst → discovery, reviewers → frontend/ios/flutter/backend.

**Escalate-on-ambiguity rule:** the architect (and any downstream agent) does **not** invent answers
to fill a real gap. When a decision needs *confirmation rather than an assumption*, it stops and asks
the user. Assumptions are only acceptable when explicitly low-risk and recorded in the artifact.

**Loop policy:** after fixes, `/feature` re-runs the relevant reviewers and loops
build → review → fix → re-review until **green — zero open blocker and major findings** (minors may
ship, listed in the report) — or **3 rounds** are reached, then reports to the user. If blockers or
majors remain at the cap, the report opens with an explicit **NOT SHIPPABLE** status.

**Worktree isolation:** every initiative runs in its own git worktree, created at Setup and merged back
into `develop` automatically once it ships green — see §9. This makes concurrent `/feature` sessions
safe without you having to opt in.

## 3. Folder & naming conventions

The pipeline machinery — the 13 agents, the `/feature` skill, the `/initialize` command, the stack-skill
manifest, `bootstrap.sh`, and the artifact templates — is provided by the **cc-setup plugin** and is
never copied here (agents reference it via `${CLAUDE_PLUGIN_ROOT}`). This project only holds this
`CLAUDE.md` and the artifacts the pipeline writes:

```
CLAUDE.md                         # this file (the only per-project config)
docs/
  discovery/<slug>.md                       # GO/PIVOT/KILL verdict + kill criteria
  requirements/<slug>-business-requirements.md
  product/<slug>-product-spec.md
  architecture/<slug>/spec.md
  architecture/<slug>/tasks/NN-<title>.md   # each tagged owner: frontend|ios|flutter|backend
  design/<slug>/design.md                   # designer's contract (UI initiatives)
  reports/<slug>/completion-report.md
  reports/<slug>/review.md
  reviews/<slug>/gates.md                     # codex gate log — the audit trail for the four spec gates
apps/        # client apps (web / mobile)
services/    # backend services
```

**`<slug>`** is the initiative key (e.g. `<example-slug>`). `/feature` assigns it at intake
from the brief and it is threaded through every artifact path. It is how the traceability spine is
followed end to end. One slug = one initiative/epic. For large scope, `/feature` splits the work into
ordered **phases** at intake (each its own `<project>-phase-N-<name>` slug) and runs the pipeline per
phase — you don't have to ask; routine features stay a single slug.

## 4. Domain defaults

> **Mandatory intake:** on a new project these MUST be **interviewed for and recorded here before any
> pipeline work** — `/feature` runs the bootstrap interview and stops at a human gate. **Never
> inherit these from a prior project**; no agent may assume them. While any `<PLACEHOLDER>` below
> remains, the project is unconfigured.

These hold unless an artifact explicitly overrides them. Replace with your project's reality:

- **Region / market:** <TARGET_MARKET>.
- **Audience / constraints:** <WHO_THE_USERS_ARE_AND_ANY_PRIVACY_OR_SAFETY_OR_COMPLIANCE_CONSTRAINTS —
  e.g. data minimization, role/authz boundaries, sensitive-data confidentiality, accessibility, no
  dark patterns>.
- **Localization:** <LANGUAGES_AND_RTL_REQUIREMENTS, OR "single-language, no RTL">.

## 5. Stack defaults

> Same intake rule as §4: interviewed for and recorded here on a new project; never inherited from a
> prior project. The architect may record a per-task deviation with a one-line rationale.

- **Web:** <WEB_STACK — e.g. Next.js, or "none"> → build agent `frontend`, bootstrap key `web`
- **Mobile:** <MOBILE_STACK — "iOS (SwiftUI)", "Flutter", "both", or "none"> → agents `ios` / `flutter`, keys `ios` / `flutter`
- **Backend:** <BACKEND_STACK — one of ".NET Web API", "Supabase", "Firebase", custom, or "none"> → agent `backend`, key `.net` / `supabase` / `firebase`
- **Automation / workflows:** <AUTOMATION_STACK — e.g. n8n, or "none">
- **AI features:** <AI_DEFAULTS — e.g. default to the latest Claude models, or "none">

**Stack skills.** The cc-setup plugin's `skills.manifest.json` maps each stack to the specialist skills
that help build it (e.g. `.NET` backend → the `/dotnet-clean-arch` skill). Run `/bootstrap <stack…>`
once per project to install the matching ones; the **build agents** (frontend·ios·flutter·backend) then
invoke them when the stack above matches (see their agent files). Skills are declared, not vendored —
they stay in sync with upstream and only the ones your stack needs get installed. To refresh installed
skills to their latest upstream, re-run the same command with `--update` (e.g.
`/bootstrap --update <stack…> roles`). Run `/bootstrap` as a Claude Code command, not a raw shell
command — it wraps `bootstrap.sh` and resolves `${CLAUDE_PLUGIN_ROOT}`, which only exists inside
Claude Code's own tool calls.

## 6. Coding standards

Write code that is **clean, SOLID, DRY, and YAGNI — but SIMPLE above all.**

- Apply SOLID/DRY/YAGNI to *reduce* complexity, never to add it. If satisfying a principle introduces
  abstraction the current requirement doesn't need, don't — the code-reviewer will flag exactly that.
- No speculative generality. Build for the v1 scope in the product spec, not imagined futures.
- Match the style, naming, and idiom of surrounding code.
- Security and privacy are requirements, not extras (see §4).

**Commit discipline.** Commit at **every small, meaningful step** — one logical change per commit, with
a clear message describing what and why. Don't batch unrelated changes into one commit, and don't wait
until a whole task is finished: each self-contained increment that builds/passes is its own commit.
This keeps history reviewable and every step easy to revert. The build agents (frontend, ios, flutter, backend)
commit as they go; `/feature` never squashes these into a single end-of-task commit.

**Artifact writing standard — mandatory.** Every document artifact the pipeline produces (discovery
brief, business requirements, product spec, architecture spec, task files, design contract, completion
report, reviews) is written for a reader with ADHD. The authoring agent **must** invoke
**`/i-have-adhd:i-have-adhd`** and shape the artifact to it — this is not optional and not conditional
on the document's length. In practice: lead with the decision or action, number anything multi-step,
one bounded idea per bullet, no preamble and no closing recap, concrete numbers instead of vague
qualifiers, and cap any list at five items (split into "now" vs "later" past that). Substance is never
cut to hit the shape — an artifact that drops a requirement to look shorter has failed both standards.
The codex gates check the artifact against this, so a wall-of-prose spec gets sent back.

## 7. Traceability spine (must be preserved end to end)

```
validated risk + v1 boundary (discovery brief, VR-n)
   → business outcome (BR)
      → product story + Gherkin acceptance criterion (product spec)
         → architect task (owner-tagged)
            → implementation (code + completion-report)
               → qa / api verification against that exact criterion (review)
```

Every artifact references the one above it: requirements cite the validated problem discovery handed
over; tasks cite the story/AC they satisfy; the completion report cites the tasks; the review cites the
AC each finding maps to. If you cannot trace a piece of work back to a business outcome — and that
outcome back to a risk discovery actually validated — that is a signal to hand backward, not to
proceed. Work that traces to nothing discovery validated is scope that crept in past the gate.

## 8. Apply YAGNI to the team itself

No roles, files, or ceremony that won't actually be used. Keep artifacts as short as they can be while
still carrying the spine.

## 9. Parallel sessions (git worktrees)

> **This section is the authority on this project's git policy, and you may replace it wholesale.**
> What follows is the shipped default, not a requirement. If this project already has its own worktree,
> branching, or merge convention — a different granularity (one worktree per *edit* rather than per
> initiative), a different base or merge target, or a review requirement before merge — **write that
> here instead**, and `/feature` follows it. A project's own git policy beats the plugin's default;
> `/feature` is told not to impose the convention below over whatever this section says, and to ask
> rather than guess if the two can't be reconciled. `/initialize --sync` will not silently overwrite a
> §9 you have customized.

`/feature` isolates **every** initiative in its own git worktree automatically, not just when you
remember to ask for it — this is what makes running more than one `/feature` session against this repo
at the same time safe by default; without it, concurrent sessions would stomp each other's uncommitted
changes and branch state in a shared working directory.

- **At Setup**, `/feature` creates `git worktree add .worktrees/<slug> -b feature/<slug> develop`
  (falling back to the current branch if `develop` doesn't exist) and ensures `.worktrees/` is
  gitignored. Every dispatched agent and every commit for that initiative happens inside that worktree.
- **On completion**, once the initiative ships green, `/feature` merges back into `develop` locally —
  `git checkout develop && git merge --no-ff feature/<slug>` — resolving any conflicts before calling
  the initiative done; it never drops a conflicting hunk or forces one side to win without checking
  intent against both changes.
- **Cleanup** — once merged, `/feature` removes the worktree (`git worktree remove .worktrees/<slug>`)
  and deletes the branch (`git branch -d feature/<slug>`).
- If the initiative hits the 3-round loop cap and reports `NOT SHIPPABLE`, the worktree and branch are
  left in place (not merged) so the next session can resume the fix.
