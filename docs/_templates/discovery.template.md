# Discovery Brief — <idea title>

- **Slug:** <slug>
- **Author:** discovery
- **Status:** Draft | Approved
- **Source brief:** <path, e.g. thoughts.md>

> The decision record for whether this idea should exist. Only §8 (Handoff to BA) crosses the gate —
> everything above it is the user's evidence trail, not a requirements input.

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

- <e.g. "If fewer than 8 of 30 interviewed users describe this problem unprompted by 2026-08-15, stop.">

## 8. Handoff to BA
> **GO / PIVOT only** — on KILL, delete this section and hand nothing forward. This is the *only*
> section the business-analyst reads.

- **Validated problem statement:** <the problem, as evidence supports it — not the solution>
- **Scope boundary for v1:** <what the smallest value-testing version must cover>
- **Explicitly OUT of scope for v1:** <the cuts, so the BA does not recover needs for them>
- **Carried assumptions:** <accepted [ASSUMPTION]s the BA must treat as unvalidated, by VR-n ID>
