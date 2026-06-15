# Review — <initiative title>

- **Slug:** <slug>
- **Written by:** conductor (consolidated from code-reviewer, qa-tester, api-tester)
- **Round:** <1 | 2 | 3>
- **Verdict:** GREEN (no open issues) | issues open (see Routed fixes)

> Reviewers return findings to the conductor; the conductor writes this single file to avoid
> parallel-write clobber.

## Code review  (from code-reviewer)
| # | Finding | File / location | Severity | Owner |
|---|---|---|---|---|
| C1 | <clean/SOLID/DRY/YAGNI/SIMPLE issue — incl. over-engineering> | <path> | blocker/major/minor | frontend/backend |

## QA — browser  (from qa-tester)
| # | Story / AC | Result | Evidence | Severity | Owner |
|---|---|---|---|---|---|
| Q1 | US-1 / Scenario … | pass/fail | <what was observed> | … | frontend/backend |

## API  (from api-tester)
| # | Endpoint / AC | Scenario (incl. validation/authz) | Result | Severity | Owner |
|---|---|---|---|---|---|
| A1 | <method path> / US-1 | <error/validation/authz case> | pass/fail | … | backend |

## Routed fixes  (conductor)
| Fix | From finding | Routed to | Maps to AC | Status |
|---|---|---|---|---|
| <description> | C1 / Q1 / A1 | frontend/backend | US-n / Scenario | open/fixed |

## Loop status
- Round <n> of max 3. Next: <re-review / report to user / backward handoff to PM>.
