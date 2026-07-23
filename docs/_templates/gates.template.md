# Gate log — <initiative title>

- **Slug:** <slug>
- **Written by:** orchestrator (`/feature`) — the only writer of this file
- **What this is:** the audit trail that replaces human approval on the four spec gates. Codex reviews
  the artifact, codex-reviewer challenges the review, and the exchange is recorded here.

> One section per gate, appended as the pipeline advances. Never rewrite a closed gate — a later round
> is a new subsection, so the disagreement history stays readable.

---

## Gate: discovery · round <n>

- **Artifact:** `docs/discovery/<slug>.md`
- **Reviewed revision:** `<git hash-object output>` — the verdict below is valid only for these bytes.
  Re-hash before advancing; a mismatch means the artifact changed after approval and the gate must re-run.
- **Verdict:** APPROVE | NEEDS-ATTENTION | CODEX-UNAVAILABLE → human gate
- **Outcome:** advanced | sent back to discovery | escalated to user
- **Codex summary:** <verbatim>

| # | Sev | Finding | Location | Adjudication | Result |
|---|---|---|---|---|---|
| X1 | blocker/major/minor | <title> | <quote or §n> | agreed / disputed-conceded / disputed-revised / disputed-escalated | routed / dropped / open |

The table is the index. Each routed finding also needs its full text — the fix is routed from these,
not from the title:

**X1 — <title>** · <severity> · <location>
- **What Codex found:** <body, verbatim>
- **Recommended fix:** <recommendation, verbatim>

### Disputes

**X1 — <title>**
- **Codex:** <the finding, verbatim>
- **Challenge (codex-reviewer):** <objection> — cited: <artifact line or path:line>
- **Codex reply:** concede | hold | revise — <verbatim reasoning>
- **Result:** dropped | stands at <severity> | **unresolved → user**

### Unresolved → user

| # | Codex position | Peer position | User decision |
|---|---|---|---|
| X1 | <one line> | <one line> | pending / upheld / dismissed |

---

## Gate: requirements · round <n>

<same shape — artifact `docs/requirements/<slug>-business-requirements.md`>

---

## Gate: product · round <n>

<same shape — artifact `docs/product/<slug>-product-spec.md`>

---

## Gate: design · round <n>   *(UI initiatives only)*

<same shape — artifact `docs/design/<slug>/design.md`>

---

## Gate summary

| Gate | Rounds | Final verdict | Escalated to user |
|---|---|---|---|
| discovery | <n> | APPROVE / … | none / X1 |
| requirements | <n> | … | … |
| product | <n> | … | … |
| design | <n> / n/a | … | … |
