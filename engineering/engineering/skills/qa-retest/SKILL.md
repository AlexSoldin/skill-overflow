---
name: qa-retest
description: >
  Targeted retest workflow for previously failed QA scenarios on a Linear ticket. Reads the
  most recent test report comment from the ticket, extracts every ❌ FAIL scenario with its
  reproduction steps, runs only those scenarios with Playwright against a new build URL, then
  posts a focused retest comment to Linear. Use whenever the user says "retest the failed
  points", "test only what failed", "can you retest the failures", "check if the bug is fixed",
  "retest on the new build", or provides a new staging URL after a previous test run. This skill
  is essential — invoke it before doing any retest work. Do NOT use the full qa-tester skill for
  retests — this skill is purpose-built for targeted retesting and avoids redundant re-running
  of already-passing scenarios.
---

# QA Retest

This skill runs a focused retest loop: read previous report → extract failures → retest only those → post result.

---

## Phase 1 — Find the Previous Test Report

Use the Linear MCP `list_comments` tool to fetch all comments on the ticket.

Scan for a comment that looks like a test report — it will contain:
- A heading like `## 📋 Test Report` or `## Test Report`
- A results table with `✅ PASS` / `❌ FAIL` rows
- A summary section with pass/fail counts

If there are multiple test report comments, use the **most recent** one.

If no test report comment is found, stop and tell the user — this skill requires a prior report to work from. Suggest they run the full `qa-tester` skill first.

---

## Phase 2 — Extract the Failed Scenarios

From the test report comment, extract every row where the result is `❌ FAIL`.

For each failure, collect:
- **ID** — the scenario identifier (e.g. `E4`, `P2`)
- **Area / Scenario name** — what it tests
- **Steps** — the reproduction steps (from the test plan comment, if the report doesn't include them)
- **Previous failure note** — the error message or unexpected behaviour recorded in the report

If the report references steps from a separate test plan comment (which will also be on the ticket), fetch that comment too and match steps to scenario IDs.

Present the list of failures to the user before proceeding:

```
Found N failed scenario(s) to retest:
- E4: Employees number field coercion — "Employee count must be a number"
- P2: Password reset cross-field validation — error shown on wrong field
```

Ask: "Is this the right list? Should I skip any or add anything before I start?"
Wait for confirmation, then proceed.

---

## Phase 3 — Get the New Build URL

**Priority order:**

1. **User's message** — if they provided a URL directly, use that
2. **GitHub PR comments** — look for the most recent comment containing `Branch Preview URL:` — CI posts this automatically on every new build
3. **New Linear comments** — scan for any `*.coolset-react-app-stage.pages.dev` link posted after the original test report
4. **Ask the user** — if none of the above has a URL, ask explicitly: "What URL should I retest on?"

If the new URL is the same as the one in the original test report, flag this to the user — the fix may not have been deployed yet.

---

## Phase 4 — Run Playwright on Failed Scenarios Only

**IMPORTANT:** The user must be logged in to the staging URL. If they are not, ask them to log in and confirm before starting.

Use the Playwright MCP plugin (`mcp__plugin_playwright_playwright__*`).

Navigate to the staging URL root first to confirm the session is alive. If redirected to `/login`, stop and ask the user to log in.

### Execution

Work through **only the previously failed scenarios** in order.

For each scenario:
1. Navigate to the relevant route
2. Reproduce the exact steps from the test plan (the same sequence that caused the failure before)
3. Observe whether the bug is still present
4. Record the result with a precise observation — don't just say "it works", describe what you saw

### Result tracking

```
| ID | Scenario | Previous result | New result | Observation |
|----|----------|-----------------|------------|-------------|
| E4 | Employees number coercion | ❌ FAIL | ✅ PASS | No error after clear + retype + submit |
| P2 | Password cross-field validation | ❌ FAIL | ❌ STILL FAILING | Error still shown on wrong field |
```

### Codebase-specific patterns (coolset-react-app)

- Number spinbutton bug reproduction: `fill('')` to clear, then `type('value')` to retype as a string — this is the exact sequence that triggers coercion bugs
- Cross-field validation (password): trigger by blurring the repeat-password field after entering a mismatched value
- Survey auto-save: verify via progress bar percentage change, not a submit button
- Session check: confirm `/` loads the dashboard before navigating to deep links

---

## Phase 5 — Post the Retest Report to Linear

After all failed scenarios are retested, post a concise retest comment to the ticket.

Format:
```markdown
## 🔁 Retest — [Ticket Title]

**New build:** [url]
**Date:** [today]
**Retested:** [N] previously failed scenario(s)

| ID | Scenario | Before | After | Notes |
|----|----------|--------|-------|-------|
| E4 | [scenario] | ❌ FAIL | ✅ PASS | [what changed / what was observed] |
| P2 | [scenario] | ❌ FAIL | ❌ STILL FAILING | [still broken — describe the behaviour] |

### Summary
- **Fixed:** X / N
- **Still failing:** X / N

### Still Failing — Details
[For each scenario that still fails, include:]
- What was observed
- Whether root cause is identifiable from the error
- Suggested next step

### Verdict
✅ All failures resolved — ready to merge.
OR
⚠️ [N] scenario(s) still failing — needs further investigation.
```

---

## Quick Reference Checklist

- [ ] Most recent test report found on the ticket
- [ ] All ❌ FAIL scenarios extracted with IDs and steps
- [ ] List of failures confirmed with user
- [ ] New build URL identified
- [ ] New URL is different from the original (fix was deployed)
- [ ] User confirmed they are logged in to the new build
- [ ] Each failed scenario retested using the exact original reproduction steps
- [ ] Results recorded as PASS or STILL FAILING with observations
- [ ] Retest report posted to Linear
