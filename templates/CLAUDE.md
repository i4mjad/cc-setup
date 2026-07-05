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

Eleven specialist agents run a requirements → build → verify pipeline, orchestrated by the
**`/feature`** skill (run by the main thread — there is no conductor agent). The **build agents are
platform-scoped**: `frontend` (web), `ios`, `flutter`, and an adaptive `backend` — `/feature`
dispatches only the ones whose platform is set in §5.

```
      ┌── gate ──┐   ┌── gate ──┐              ┌── gate, if UI ──┐
business-analyst ▶ product-manager ▶ architect ▶ designer ▶ frontend ┐
                                                           ios       │
                                                           flutter   ├─▶ completion-report
                                                           backend   ┘        │
                                        ┌── code-reviewer ──┐                 │
                                        ├── qa-tester ──────┤◀────────────────┘
                                        └── api-tester ─────┘
                                                │ (findings → /feature → review.md)
                                                ▼
                                 routed fixes ─▶ frontend / ios / flutter / backend
                                                │
                                     auto-loop ≤ 3 rounds, then report to user
```

- **`/feature`** orchestrates (the main thread, not a subagent): assigns the initiative `<slug>`,
  invokes each agent in order, runs the **present** client agents (frontend/ios/flutter) + backend in
  parallel and the three reviewers in parallel, writes the consolidated `review.md`, routes fixes,
  loops, and stops at the human gates. It never does requirements, design, or coding itself. Start an
  initiative with `/feature <brief>`.

### Handoff rules

| Handoff | Type |
|---|---|
| bootstrap intake interview → pipeline (new project only) | **HUMAN GATE** — stop for user approval of the filled §4/§5 defaults |
| business-analyst → product-manager | **HUMAN GATE** — stop for user approval |
| product-manager → architect | **HUMAN GATE** — stop for user approval |
| architect → designer (only if the initiative has UI) | automatic |
| designer → build agents | **HUMAN GATE** — stop for design approval (UI initiatives only) |
| architect / designer → frontend·ios·flutter + backend (present platforms) | automatic |
| build agents → reviewers | automatic |
| reviewers → build agents (routed fixes) | automatic, via `/feature` |

**Backward handoffs** are allowed and expected when work upstream is wrong/ambiguous:
architect → product-manager, designer → product-manager, product-manager → business-analyst,
reviewers → frontend/ios/flutter/backend.

**Escalate-on-ambiguity rule:** the architect (and any downstream agent) does **not** invent answers
to fill a real gap. When a decision needs *confirmation rather than an assumption*, it stops and asks
the user. Assumptions are only acceptable when explicitly low-risk and recorded in the artifact.

**Loop policy:** after fixes, `/feature` re-runs the relevant reviewers and loops
build → review → fix → re-review until all issues clear or **3 rounds** are reached, then reports to
the user.

## 3. Folder & naming conventions

The pipeline machinery — the 11 agents, the `/feature` skill, the `/initialize` command, the stack-skill
manifest, `bootstrap.sh`, and the artifact templates — is provided by the **cc-setup plugin** and is
never copied here (agents reference it via `${CLAUDE_PLUGIN_ROOT}`). This project only holds this
`CLAUDE.md` and the artifacts the pipeline writes:

```
CLAUDE.md                         # this file (the only per-project config)
docs/
  requirements/<slug>-business-requirements.md
  product/<slug>-product-spec.md
  architecture/<slug>/spec.md
  architecture/<slug>/tasks/NN-<title>.md   # each tagged owner: frontend|ios|flutter|backend
  design/<slug>/design.md                   # designer's contract (UI initiatives)
  reports/<slug>/completion-report.md
  reports/<slug>/review.md
apps/        # client apps (web / mobile)
services/    # backend services
```

**`<slug>`** is the initiative key (e.g. `<example-slug>`). `/feature` assigns it at intake
from the brief and it is threaded through every artifact path. It is how the traceability spine is
followed end to end. One slug = one initiative/epic.

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
that help build it (e.g. `.NET` backend → the `/dotnet-clean-arch` skill). Run
`bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh <stack…>` once per project to install the matching
ones; the **build agents** (frontend·ios·flutter·backend) then invoke them when the stack above matches (see their
agent files). Skills are declared, not vendored — they stay in sync with upstream and only the ones
your stack needs get installed.

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

## 7. Traceability spine (must be preserved end to end)

```
business outcome (BR)
   → product story + Gherkin acceptance criterion (product spec)
      → architect task (owner-tagged)
         → implementation (code + completion-report)
            → qa / api verification against that exact criterion (review)
```

Every artifact references the one above it: tasks cite the story/AC they satisfy; the completion
report cites the tasks; the review cites the AC each finding maps to. If you cannot trace a piece of
work back to a business outcome, that is a signal to hand backward, not to proceed.

## 8. Apply YAGNI to the team itself

No roles, files, or ceremony that won't actually be used. Keep artifacts as short as they can be while
still carrying the spine.
