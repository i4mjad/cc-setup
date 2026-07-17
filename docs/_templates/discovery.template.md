# Discovery Brief — <idea title>

- **Slug:** <slug>
- **Author:** discovery
- **Status:** Draft | Approved
- **Source brief:** <path, e.g. thoughts.md>

> The decision record for whether this idea should exist. Only §8 (Handoff to BA) crosses the gate —
> everything above it is the user's evidence trail, not a requirements input.
>
> **Keep it short enough to read at the gate** (CLAUDE.md §8) — one row per finding that could change
> the verdict, and none that couldn't. A risk with nothing to say gets one line saying so, not a
> paragraph explaining why it has nothing to say. Length is not thoroughness; a verdict nobody reads
> is a gate nobody holds.

Every claim below is tagged `[EVIDENCE]` (observed, sourced), `[ASSUMPTION]` (believed, untested —
must name its cheapest test), or `[USER-CONVICTION]` (the user's call, recorded as such). A GO may
not rest on `[USER-CONVICTION]` alone for value risk.

## 1. Idea (steelmanned)
<The strongest version of the idea, in one paragraph, confirmed by the user before any challenge.>

## 2. Verdict
**GO | PIVOT | KILL** — <one sentence of justification. If the idea is weak, say where and why here.>

## 3. Value risk
> Who has this problem, how do they solve it today, and what proof exists that they'd switch?

| ID | Finding | Tag | Open question / cheapest test |
|---|---|---|---|
| VR-1 | <finding> | [EVIDENCE] | <n/a, or the test that would settle it> |

- **Evidence path:** <interviews / waitlist / existing-behavior signal / competitor traction — at least one>

## 4. Viability risk
> Does it work for *this* team in *this* market? Pricing, distribution, the compliance constraints in
> CLAUDE.md §4, unit economics, maintenance burden alongside existing commitments.

| ID | Finding | Tag | Open question / cheapest test |
|---|---|---|---|
| VR-n | <finding> | [ASSUMPTION] | <how we'd test it cheaply> |

## 5. Usability risk
> Can the §4 audience figure it out? What is the smallest surface that tests this?

| ID | Finding | Tag | Open question / cheapest test |
|---|---|---|---|
| VR-n | <finding> | [ASSUMPTION] | <how we'd test it cheaply> |

## 6. Feasibility risk
> Only after the three above. Buildable with the CLAUDE.md §5 stack, in the time available?

- **Smallest buildable test of value:** <the minimum thing that produces a real signal>
- **YAGNI cuts:** <what is explicitly NOT built to get that signal, and why it can wait>

| ID | Finding | Tag | Open question / cheapest test |
|---|---|---|---|
| VR-n | <finding> | [EVIDENCE] | <n/a, or the test> |

## 7. Kill criteria
> Falsifiable, with numbers and a deadline. "If fewer than X of Y do Z within T, stop."
> Vague criteria are a failure — rewrite until falsifiable.
>
> On a **KILL**, kill criteria do not apply — they guard a GO. State instead which findings, if any,
> could ever reopen this, and name the ones that no amount of demand unblocks (a legal or ethical
> bar is not a threshold). If nothing could reopen it, say that.

- <e.g. "If fewer than 8 of 30 interviewed users describe this problem unprompted by 2026-08-15, stop.">

## 8. Handoff to BA
> This is the *only* section the business-analyst reads.
>
> On a **KILL**, do not delete this section — an absent section is ambiguous (forgotten, or dead?).
> Keep the heading and write exactly one thing: **"None — this is a KILL. Nothing is handed forward
> and the pipeline stops here."** Then state plainly what is dead and on which risk, so the record
> can't be re-read later as a deferral. If a *different* idea sits underneath this one, say that it is
> a new idea needing its own discovery — not this one surviving in another form.

- **Validated problem statement:** <the problem, as evidence supports it — not the solution>
- **Scope boundary for v1:** <what the smallest value-testing version must cover>
- **Explicitly OUT of scope for v1:** <the cuts, so the BA does not recover needs for them>
- **Carried assumptions:** <accepted [ASSUMPTION]s the BA must treat as unvalidated, by VR-n ID>
