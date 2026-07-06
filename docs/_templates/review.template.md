# Review — <initiative title>

- **Slug:** <slug>
- **Written by:** orchestrator (consolidated from code-reviewer, qa-tester, api-tester)
- **Round:** <1 | 2 | 3>
- **Verdict:** GREEN (zero open blockers and majors; minors listed) | issues open (see Routed fixes) |
  NOT SHIPPABLE (blockers/majors remain at the 3-round cap)

> Reviewers return findings to the orchestrator; the orchestrator writes this single file to avoid
> parallel-write clobber.

## Code review  (from code-reviewer)
| # | Finding | File / location | Severity | Owner |
|---|---|---|---|---|
| C1 | <clean/SOLID/DRY/YAGNI/SIMPLE issue — incl. over-engineering> | <path> | blocker/major/minor | frontend/ios/flutter/backend |

## QA — browser  (from qa-tester)
| # | Story / AC | Result | Evidence | Severity | Owner |
|---|---|---|---|---|---|
| Q1 | US-1 / Scenario … | pass/fail | <what was observed> | … | frontend/ios/flutter/backend |

## API  (from api-tester)
| # | Endpoint / AC | Scenario (incl. validation/authz) | Result | Severity | Owner |
|---|---|---|---|---|---|
| A1 | <method path> / US-1 | <error/validation/authz case> | pass/fail | … | backend |

## Routed fixes  (orchestrator)
| Fix | From finding | Routed to | Maps to AC | Status |
|---|---|---|---|---|
| <description> | C1 / Q1 / A1 | frontend/ios/flutter/backend | US-n / Scenario | open/fixed |

## Loop status
- Round <n> of max 3. Next: <re-review / report to user / backward handoff to PM>.
