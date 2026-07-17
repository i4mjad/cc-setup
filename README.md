# cc-setup

A reusable **Claude Code plugin**: a **discovery → design → build → verify** agent team plus a
stack-aware skill set. Twelve specialist agents run a single pipeline, orchestrated by the **`/feature`**
skill, that takes a raw idea all the way to reviewed, verified code — stopping at human approval gates
along the way. It opens by asking whether the idea should be built at all, and can tell you no. The
build agents are **platform-scoped**, so a web-only app and a web + iOS + Flutter app each get exactly
the agents they need.

Install it once and it's available in **every** project — no copy-paste. The plugin's own files
(agents, commands, hooks, templates) update via `claude plugin update`; the third-party stack/role
skills installed by `bootstrap.sh` are separate installs, refreshed from their own upstreams with
`bootstrap.sh --update` (see [Bootstrap](#bootstrap)).

## Install

Prerequisites: the `claude` CLI, plus `jq`, `npx`, and network access for `bootstrap.sh`.

**1. Install the plugin (once, globally):**

```bash
claude plugin marketplace add i4mjad/cc-setup   # register this repo as a marketplace
claude plugin install cc-setup@cc-setup         # install the plugin
```

Then **restart Claude Code** so the agents, `/initialize`, and `/feature` load.

To update later: `claude plugin update cc-setup@cc-setup`. To develop locally, point the marketplace at
a checkout instead: `claude plugin marketplace add /path/to/cc-setup`.

> **After a plugin update, run `/initialize --sync` in each existing project.** The agents, `/feature`,
> and the templates update themselves — but your project's own `CLAUDE.md` does not, because
> `/initialize` never overwrites it. Its §2/§3/§6–§9 are plugin-owned boilerplate (pipeline, folder
> conventions, standards, traceability, worktrees) and go stale on a pipeline change, while §1/§4/§5
> hold your interviewed purpose/domain/stack. `--sync` refreshes the former and leaves the latter
> untouched. Skipping it leaves your governance file describing a pipeline the plugin no longer runs —
> and every agent reads that file first. **Upgrading from 0.8.x specifically:** your §2 still starts at
> business-analyst with a stale agent count, and has no discovery stage and no KILL gate.

**2. Scaffold a project (once per project):**

```
/initialize
```

`/initialize` writes a starter `CLAUDE.md` and interviews you for the **project shape** — full-stack web vs
full-stack + mobile, which mobile (iOS / Flutter / both), and which backend (.NET / Supabase / Firebase /
custom). It records that in `CLAUDE.md §5`, which decides exactly which build agents `/feature` dispatches.
(Named `initialize`, not `init`, to avoid clashing with Claude Code's built-in `/init`.)

`/initialize --sync` is the re-run: it refreshes only the plugin-owned pipeline sections of an existing
`CLAUDE.md` (§2/§3/§6–§9), preserves your §1/§4/§5 verbatim, and reports what changed. Use it after
every `claude plugin update`.

> **`--sync` only rewrites files that are still template-derived.** If your project's `CLAUDE.md` was
> hand-written or restructured — its own section names, its own agent names, its own git policy — there
> are no template sections to swap, and `--sync` switches to **report-only**: it prints the delta
> between the current pipeline and your file for you to hand-merge, and changes nothing. That's the
> intended outcome, not a failure; a file someone deliberately authored isn't drift. `--sync` also
> leaves a customized **§9** alone in every case — §9 is your git policy and outranks the plugin's
> default (see below).

**3. Install the skills your stack needs (once per project):**

```
# /initialize prints the exact command; e.g. a web + iOS app on Supabase:
/bootstrap web ios supabase roles
```

Run this as a **Claude Code command**, not a raw shell command — `/bootstrap` wraps `bootstrap.sh` and
runs it through Claude Code's own tool calls, where `${CLAUDE_PLUGIN_ROOT}` resolves. Pasting
`bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh ...` straight into a plain terminal fails — that
variable doesn't exist outside Claude Code.

**4. Run the pipeline (any time):**

```
/feature <brief>
```

Only `CLAUDE.md` is written into your project — everything else lives in the plugin (referenced via
`${CLAUDE_PLUGIN_ROOT}`).

> **Optional — issue tracker for `/wayfinder`:** the business-analyst can use `/wayfinder` to plan
> large, multi-session efforts as decision tickets. It needs a tracker: run `/setup-matt-pocock-skills`
> and choose **github** (install & authenticate the `gh` CLI: `gh auth login`), **gitlab**, or
> **local markdown**. Linear isn't supported upstream. Skip this and the agent just uses `/grill-me`.

## The 12 agents

| Agent | Role |
|---|---|
| **discovery** | Raw idea → Discovery Brief with a **GO / PIVOT / KILL** verdict. Challenges value → viability → usability → feasibility, in that order, and stops the pipeline on a KILL. |
| **business-analyst** | Validated idea → solution-agnostic business-requirements doc. Interviews you on blocking gaps. |
| **product-manager** | Business requirements → product spec (MoSCoW scope, v1 vs deferred, Gherkin AC). Answers "what," never "how." |
| **architect** | Product spec → technical decisions + owner-tagged build tasks (`owner: frontend\|ios\|flutter\|backend`). |
| **designer** | Architecture → `design.md`, a platform-aware design contract the client agents implement to. Runs only for UI initiatives. |
| **frontend** | Web client tasks (`owner: frontend`). |
| **ios** | Native iOS / SwiftUI tasks (`owner: ios`). |
| **flutter** | Cross-platform Flutter tasks (`owner: flutter`). |
| **backend** | Server/API/data tasks (`owner: backend`) — adapts to the one backend platform in §5. |
| **code-reviewer** | Reviews for clean / SOLID / DRY / YAGNI code that stays SIMPLE. Findings only. |
| **qa-tester** | Browser-tests against the Gherkin AC via the Playwright MCP. |
| **api-tester** | Exercises endpoints — scenarios, error handling, validation, auth. |

The pipeline itself is the **`/feature`** skill (main thread) — it assigns the slug, invokes each agent
in order, runs the **present** client agents + backend in parallel, consolidates the review, routes
fixes, loops, and stops at the human gates. (No separate conductor agent.)

## Flow

```
discovery ─[GATE]─▶ business-analyst ─[GATE]─▶ product-manager ─[GATE]─▶ architect ─▶ designer ─[GATE, if UI]─▶
   frontend / ios / flutter + backend (only the platforms in §5, parallel) ─▶ completion-report
      ─▶ code-reviewer + qa-tester + api-tester (parallel)
         ─▶ /feature consolidates review, routes fixes ─▶ the tagged build agent
            ─▶ loop ≤ 3 rounds, then report to the user

   discovery returns KILL ─▶ pipeline stops; nothing reaches the business-analyst
```

- **Human gates**: after discovery, after business-analyst, after product-manager, and after designer
  (UI only).
- **Discovery can say no.** Every initiative starts there, and a **KILL** stops the pipeline — only you
  can overrule it. On GO/PIVOT only the brief's *Handoff to BA* section crosses the gate, and its
  out-of-scope cuts bind everything downstream. It reads your `CLAUDE.md` §4/§5 for the market,
  compliance, and stack a GO has to survive.
- **Large scope auto-phases**: after discovery, `/feature` sizes up what the v1 boundary left on its own
  — if it's too big for one pass (e.g. a new project from scratch), it proposes an ordered set of
  shippable **phases** (`<project>-phase-N-<name>`), gets your approval, then runs the rest of the flow
  once per phase. You don't have to ask for this; routine features stay a single phase. Discovery isn't
  re-run per phase.
- **Backward handoffs** expected when upstream is wrong/ambiguous (architect → PM → BA → discovery;
  designer → PM).
- **Escalate-on-ambiguity**: downstream agents stop and ask rather than guess.
- **Worktree isolation**: by default `/feature` runs every initiative in its own git worktree off
  `develop` and merges it back automatically once it ships green — safe to run more than one `/feature`
  session on this repo at a time. This is a **default, not a mandate**: `CLAUDE.md §9` is the project's
  git policy and outranks it, so a repo with its own worktree/branch/merge convention writes it there
  and `/feature` follows that instead.

## Stack skills

`skills.manifest.json` maps each stack to its build skills — **declared, not vendored**. Backend keys are
mutually exclusive; frontend keys coexist.

| Key | Agent | Skill(s) | Source |
|---|---|---|---|
| `web` | frontend | `/tailwind-design-system`, `/accessibility`, ReUI MCP + skills | wshobson/agents, addyosmani/web-quality-skills, mcp.reui.io |
| `ios` | ios | `swiftui-expert` | AvdLee/SwiftUI-Agent-Skill (plugin) |
| `flutter` | flutter | official `flutter/skills` suite | flutter/skills (20K+/skill) |
| `.net` | backend | `/dotnet-clean-arch` | i4mjad/dotnet-clean-arch-skill |
| `supabase` | backend | `/supabase`, `/supabase-postgres-best-practices` | supabase/agent-skills (official) |
| `firebase` | backend | official `firebase/*` suite | firebase/agent-skills (official) |

## Role skills

Always-on per pipeline agent (the `roles` section):

| Agent | Role skill | Source |
|---|---|---|
| discovery | `/grill-me` | mattpocock/skills (454K) |
| business-analyst | `/grill-me`, `/wayfinder`¹ | mattpocock/skills (454K) |
| product-manager | `/to-prd`, `/to-issues` | mattpocock/skills |
| architect | `/architecture-designer` | jeffallan/claude-skills |
| designer | `/design-taste-frontend`, `/high-end-visual-design`, `/refactoring-ui-skills`, figma, Mobbin MCP | leonxlnx/taste-skill (217K), plugins/MCP |
| code-reviewer | `/ponytail-review`, `/ponytail-audit`, `/code-review-graph:review-delta` | plugins |
| qa-tester | Playwright MCP | `playwright` plugin |
| api-tester | `/api-testing` | secondsky/claude-skills |

¹ `/wayfinder` is optional, for efforts too big for one session. It needs an issue tracker — run
`/setup-matt-pocock-skills` and pick **github** (via the `gh` CLI, authenticated with `gh auth login`),
**gitlab**, or **local markdown**. There is no Linear tracker upstream. Without a tracker configured,
the business-analyst stays on `/grill-me`.

## Bootstrap

`/bootstrap` is a Claude Code command that wraps `scripts/bootstrap.sh` — use it instead of running the
script directly in a terminal (see the note in [Install](#install)). Install exactly what a project's
shape needs:

```
# a web + iOS app on Supabase, plus every role skill:
/bootstrap web ios supabase roles
/bootstrap roles         # all role skills
/bootstrap --dry-run web # preview commands
/bootstrap                # list every key
```

**Update installed skills** from their upstreams (they track default branches, so this pulls the
latest) with the same keys plus `--update`:

```
/bootstrap --update roles          # refresh every role skill
/bootstrap --update web ios roles  # refresh a whole project's set
```

Each agent invokes its skill **if present** — skip an install and the agent falls back to its own
prompt, so nothing breaks. `bootstrap.sh` reports any failed install explicitly (exit code 1 with a
summary) so a fallback never happens silently.

**Picking up new manifest entries** (an existing project that scaffolded before a skill was added to
`skills.manifest.json`): run `claude plugin update cc-setup@cc-setup` to pull the updated manifest, then
re-run the **plain** (non-`--update`) form for the affected key, e.g. `/bootstrap web` — it installs
whatever is new and safely re-runs whatever you already have. Use the plain form, not `--update`, for
this: `--update` assumes every `plugin`-kind entry under that key is already installed (it runs
`claude plugin update` instead of `install`), which fails on an entry that's newly added.

> Scripting/CI, where there's no Claude Code session to resolve `${CLAUDE_PLUGIN_ROOT}`: run
> `scripts/bootstrap.sh` directly with the plugin's real path, e.g.
> `bash ~/.claude/plugins/cache/cc-setup/cc-setup/<version>/scripts/bootstrap.sh web`.

> **Supply-chain note:** the manifest's skill refs point at third-party repos and track their default
> branches — they are not version-pinned (the installers don't support commit pins). Review what you
> install; an upstream rename or deletion surfaces as an explicit bootstrap failure.

## What's in the plugin

```
.claude-plugin/{marketplace,plugin}.json   # marketplace + plugin manifests
agents/*.md                                # the 12 specialist agents (auto-discovered)
skills/feature/SKILL.md                    # the /feature pipeline orchestrator
commands/initialize.md                     # the /initialize project scaffolder
hooks/                                     # PreToolUse guard enforcing the write boundaries
templates/CLAUDE.md                        # the starter governance /initialize writes
skills.manifest.json                       # stack + role → skills map
scripts/bootstrap.sh                       # installs the skills your project needs
scripts/validate.sh                        # the plugin's own consistency checks (run by CI)
docs/ORCHESTRATION.md · docs/_templates/   # pipeline reference + artifact templates
```

**Enforced boundaries:** the reviewer agents (code-reviewer, qa-tester, api-tester) declare read-only
`tools:`, and a PreToolUse hook blocks any subagent writing `review.md`, reviewers writing files, and
spec/design agents writing app code — the pipeline's rules are mechanical, not just prompts.

## Local development / dogfooding

```bash
claude plugin marketplace add /path/to/cc-setup
claude plugin install cc-setup@cc-setup
```
