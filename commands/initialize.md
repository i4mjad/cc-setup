---
description: Scaffold the cc-setup pipeline into this project — writes a starter CLAUDE.md, then interviews you to fill its domain/stack defaults. Run once per new project; re-run with --sync after a plugin update to refresh the pipeline sections.
argument-hint: [--sync]
allowed-tools: Bash(test:*), Read, Write, Edit, AskUserQuestion
---

<!--
cc-setup init — materializes the ONE genuinely per-project file (CLAUDE.md). Everything else
(the 13 agents, the /feature skill, the stack-skill manifest, bootstrap.sh, and the artifact
templates) lives in the plugin and is referenced by the agents via ${CLAUDE_PLUGIN_ROOT} — nothing
else is copied into the project.

CLAUDE.md is a split-ownership file, which is why --sync exists:
  - PROJECT-OWNED: §1 (purpose), §4 (domain defaults), §5 (stack defaults) — interviewed for, unique
    to this project, and NEVER touched by --sync.
  - PLUGIN-OWNED: §2, §3, §6, §7, §8, §9 — the pipeline, folder conventions, coding standards,
    traceability spine, and worktree policy. Generic boilerplate that ships from templates/CLAUDE.md.
Without --sync, a plugin update silently leaves every existing project describing the OLD pipeline in
its own governance file — which every agent reads first, and which then contradicts /feature.
-->

Arguments: $ARGUMENTS

Does this project already have a CLAUDE.md? !`test -f CLAUDE.md && echo EXISTS || echo MISSING`

Here is the current starter governance template:

@${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md

**Do this:**

0. **If `--sync` was passed:** this is a refresh of an existing project, not a scaffold. Skip
   everything else and do only this:
   - If CLAUDE.md is MISSING, say so and stop — there is nothing to sync; tell the user to run
     `/initialize` with no arguments first.
   - **First, check the file is actually template-derived** — i.e. it still has the numbered sections
     this command swaps (§2, §3, §6–§9) in recognizable template form. Many real projects' CLAUDE.md
     files are hand-written with their own structure and section names; **section swapping does not
     apply to those, and you must not force it.** If the file isn't template-derived, say so plainly
     and switch to **report-only mode**: list what the plugin's pipeline now says that this file
     doesn't (new agents, gates, artifacts, spine, loop policy), as a short delta the user can
     hand-merge, and **change nothing**. That is a successful `--sync` on a divergent file, not a
     failure — say which parts look like deliberate customization rather than drift, and never
     recommend a full overwrite of a file whose structure someone clearly authored on purpose.
   - Otherwise, read the project's `./CLAUDE.md` and replace **only** its §2, §3, §6, §7, §8, and §9
     with those sections from the template above. Preserve §1, §4, and §5 **byte-for-byte** — they hold
     this project's interviewed purpose, domain, and stack, and are not yours to touch.
   - **§9 is the project's git policy, not the plugin's.** If its §9 states a worktree/branch/merge
     convention that differs from the template's default, that is a deliberate choice — leave it alone
     and report it as kept. Never replace a customized §9 with the shipped default.
   - `<PROJECT_NAME>` and any other placeholder inside the plugin-owned sections you just wrote must
     be filled from the project's existing §1/§4/§5 — never reintroduce a `<PLACEHOLDER>` into a file
     that was already configured.
   - **Report the diff in prose before finishing**: name what changed in the pipeline (e.g. "§2 now
     has a discovery stage and a fourth human gate"). A silent rewrite of the file that governs every
     agent is not acceptable — the user must know what their governance now says.
   - If the project's §2/§3/§6–§9 were hand-edited away from the template, say so explicitly and ask
     before overwriting; a deliberate local customization is not drift.
   - Then stop. `--sync` never runs the interview and never runs the pipeline.

1. **If CLAUDE.md is MISSING:** write the template above verbatim to `./CLAUDE.md`. It is the
   governance file every cc-setup agent reads.

2. **If CLAUDE.md already EXISTS:** do NOT overwrite it. Report that it's already present, and
   mention that `/initialize --sync` refreshes the plugin-owned pipeline sections if the plugin has
   been updated since. Only continue to the interview if it still contains `<PLACEHOLDER>` markers.

3. **Interview to fill the defaults.** Using `AskUserQuestion`, interview the user in one focused batch
   and write the answers into the new `./CLAUDE.md` §1 (purpose), §4 (domain defaults) and §5 (stack
   defaults):
   - Product purpose / one-line description, and whether the repo is greenfield or existing.
   - Region / market; audience and any privacy / safety / compliance constraints.
   - Localization / RTL requirements (or single-language).
   - **Project shape** — ask explicitly, because it decides which build agents `/feature` dispatches:
     - **Full-stack web app**, or **full-stack + mobile**?
     - If mobile: **iOS (native SwiftUI)**, **Flutter (cross-platform)**, or **both**?
     - **Backend platform**: **.NET Web API**, **Supabase**, **Firebase**, custom (Node/other), or none?
   - Automation / AI defaults (or "none").
   Record the platform choices in §5 as the concrete lines (Web / Mobile / Backend). Replace every
   matching `<PLACEHOLDER>`; leave the pipeline sections (§2, §3, §6, §7, §8, §9) as-is.

4. **Install the matching skills.** Map §5 to bootstrap keys and tell the user the exact `/bootstrap`
   command to run (it wraps `bootstrap.sh` — don't hand them the raw `bash ${CLAUDE_PLUGIN_ROOT}/...`
   form, that only resolves inside Claude Code's own tool calls and fails if pasted into a plain terminal):
   - web → `web` · iOS → `ios` · Flutter → `flutter` · backend → one of `.net` / `supabase` / `firebase`.
   - Always add `roles` (the always-on per-agent skills, incl. the designer).
   e.g. a web + iOS app on Supabase → `/bootstrap web ios supabase roles`.
   List every available key with `/bootstrap`.
   If an answer maps to **no build agent** (e.g. React Native, a desktop app), say so explicitly:
   the pipeline has no client agent for it, and `/feature` would skip that platform — record it in §5
   with a "no pipeline agent" note rather than silently mapping it to the nearest key.

5. **Stop.** `/initialize` only scaffolds — it does not run the pipeline. Tell the user to start work with
   `/feature <brief>`.
