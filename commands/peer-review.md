---
description: Get an independent Codex review of a spec artifact or the current branch, then challenge it as a peer
argument-hint: '[path/to/artifact.md | <git-ref>]'
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(command:*), Task, AskUserQuestion
---

Run the same peer review the `/feature` pipeline runs at its gates, on demand and outside the pipeline.

Argument: `$ARGUMENTS`

## What this does

Dispatch the **codex-reviewer** agent. It runs an independent Codex review, then challenges every
finding against the source and returns what survives — plus anything still disputed.

## Pick the mode from the argument

| Argument | Mode |
|---|---|
| a path under `docs/discovery/` | gate mode, stage `discovery` |
| a path under `docs/requirements/` | gate mode, stage `requirements` |
| a path under `docs/product/` | gate mode, stage `product` |
| a path under `docs/design/` | gate mode, stage `design` |
| any other existing `.md` path | ask which stage rubric to use (`AskUserQuestion`, four options) |
| a git ref (branch, tag, SHA), or empty | code mode against that ref, or against the merge target in `CLAUDE.md` §9 when empty |

If the argument is a path that does not exist, say so and stop — do not guess a git ref from it.

## Report the result

Print, in this order:

1. **Verdict** — `APPROVE` / `NEEDS-ATTENTION` / `CODEX-UNAVAILABLE`.
2. **Findings table** — id · severity · title · location · adjudication.
3. **The disputes, verbatim** — Codex's finding, the challenge and its citation, Codex's reply. Do not
   compress this into a summary; the disagreement is the point.
4. **Unresolved** — every finding Codex held against the challenge, as two positions, undecided.

## Core constraint

**Review only. Change nothing.** Do not fix a finding, edit a file, or offer to. After reporting, stop
and ask which findings — if any — the user wants acted on. This holds even when a fix is one line and
obvious. Applying a review automatically is exactly the failure this stage exists to prevent.

Standalone runs write nothing to `docs/reviews/` — that file belongs to a `/feature` run. Report to the
terminal only.
