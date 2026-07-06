---
description: Scaffold the cc-setup pipeline into this project — writes a starter CLAUDE.md, then interviews you to fill its domain/stack defaults. Run once per new project.
argument-hint: (no arguments)
allowed-tools: Bash(test:*), Read, Write, AskUserQuestion
---

<!--
cc-setup init — materializes the ONE genuinely per-project file (CLAUDE.md). Everything else
(the 11 agents, the /feature skill, the stack-skill manifest, bootstrap.sh, and the artifact
templates) lives in the plugin and is referenced by the agents via ${CLAUDE_PLUGIN_ROOT} — nothing
else is copied into the project.
-->

Does this project already have a CLAUDE.md? !`test -f CLAUDE.md && echo EXISTS || echo MISSING`

Here is the starter governance template the project needs:

@${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md

**Do this:**

1. **If CLAUDE.md is MISSING:** write the template above verbatim to `./CLAUDE.md`. It is the
   governance file every cc-setup agent reads.

2. **If CLAUDE.md already EXISTS:** do NOT overwrite it. Report that it's already present. Only
   continue to the interview if it still contains `<PLACEHOLDER>` markers.

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
   matching `<PLACEHOLDER>`; leave the pipeline sections (§2, §3, §6, §7, §8) as-is.

4. **Install the matching skills.** Map §5 to bootstrap keys and tell the user the exact command:
   - web → `web` · iOS → `ios` · Flutter → `flutter` · backend → one of `.net` / `supabase` / `firebase`.
   - Always add `roles` (the always-on per-agent skills, incl. the designer).
   e.g. a web + iOS app on Supabase → `bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh web ios supabase roles`.
   List every available key with `bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh`.
   If an answer maps to **no build agent** (e.g. React Native, a desktop app), say so explicitly:
   the pipeline has no client agent for it, and `/feature` would skip that platform — record it in §5
   with a "no pipeline agent" note rather than silently mapping it to the nearest key.

5. **Stop.** `/initialize` only scaffolds — it does not run the pipeline. Tell the user to start work with
   `/feature <brief>`.
