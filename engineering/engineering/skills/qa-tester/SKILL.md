---
name: qa-tester
description: >
  Full QA workflow for testing a Linear ticket: reads the ticket, writes a structured test plan,
  posts it as a Linear comment, runs Playwright smoke tests against a staging URL, then posts a
  pass/fail report back to Linear. Use whenever the user asks to "test a ticket", "write a test
  plan for", "QA this", "smoke test", "run tests against staging", or says something like
  "can you test the changes in CS-XXXX". This skill is essential — invoke it before doing any
  test planning or Playwright work.
---

# QA Tester

This skill runs the full QA loop for a Linear ticket: plan → execute → report.

---

## Phase 1 — Read the Ticket

Use the Linear MCP tool to fetch the issue by ID.

Extract:
- **Title and description** — what is being changed?
- **PR / branch** — which staging URL or build to test?
- **Linked PRs or comments** — any prior test notes, known issues, or deploy links?
- **Attachments / sub-issues** — note anything that expands scope

If the user provided a staging URL directly, use that. Otherwise look for a deploy URL in this priority order:

1. **GitHub PR comments** — look for a comment containing `Branch Preview URL:` followed by the URL. This is the most reliable source and is automatically posted by the CI pipeline on every PR.
2. **The ticket description** — sometimes the URL is pasted manually by the developer.
3. **Linear comments** — scan recent comments for any `*.coolset-react-app-stage.pages.dev` link.
4. **Infer from branch name** — Cloudflare Pages preview patterns: `<branch-slug>.coolset-react-app-stage.pages.dev` or `<commit-hash>.coolset-react-app-stage.pages.dev`

To find the PR from the ticket: use the Linear issue's linked PR field, or search for the branch name in GitHub. Then scan the PR's comment thread for `Branch Preview URL:`.

If no URL is found after checking all of the above, ask the user before proceeding.

---

## Phase 2 — Write the Test Plan

Based on the ticket scope, write a structured test plan. Think through:

1. **What changed?** List every form, view, or behaviour touched by the PR.
2. **What could break?** Think about edge cases specific to the change (type coercions, cross-field validation, async flows, conditional rendering, etc.).
3. **What can't be tested automatically?** (e.g. routes requiring invite tokens, email flows, OAuth)

Format the test plan as a Markdown table with columns:

| ID | Area | Scenario | Steps | Expected |
|----|------|----------|-------|----------|

Group scenarios by area (e.g. Password Reset, Sign Up, Employees, Surveys, Packaging).
Give each scenario a short ID (e.g. `P1`, `E1`, `CO1`).

Aim for complete coverage but keep scenarios atomic — one observable outcome per row.
Call out untestable scenarios explicitly with a note rather than skipping them.

---

## Phase 3 — Post the Test Plan to Linear

Use the Linear MCP `save_comment` tool to post the test plan to the ticket.

Format:
```
## 🧪 Test Plan — [Ticket Title]

**Scope:** [one-line summary of what changed]
**Staging URL:** [url]
**Date:** [today]

[paste the Markdown table]

### Out of Scope / Untestable
- [list any scenarios that can't be automated]
```

Wait for confirmation that the comment was saved before proceeding to Phase 4.

---

## Phase 4 — Run Playwright Smoke Tests

**IMPORTANT:** The user must already be logged in to the staging URL in a browser session.
If they are not, ask them to log in and confirm before starting tests.

Use the Playwright MCP plugin (`mcp__plugin_playwright_playwright__*`) for all browser automation.

### Setup
- Navigate to the staging URL root first to confirm the session is alive
- If redirected to `/login`, stop and ask the user to log in

### Execution strategy
- Work through each test plan scenario in order (P1 → P2 → … → E1 → E2 → …)
- For each scenario:
  1. Navigate to the relevant route
  2. Perform the steps from the test plan
  3. Take a screenshot on failure or for key verification moments
  4. Record PASS / FAIL with a brief note on what was observed

### Recording results
Track results in this format as you go:

```
| ID | Result | Notes |
|----|--------|-------|
| P1 | ✅ PASS | [observed behaviour] |
| E1 | ❌ FAIL | [error message / unexpected behaviour] |
```

### Common patterns for this codebase (coolset-react-app)
- Routes require auth — navigate to `/` first, confirm dashboard loads before deep links
- Form inputs are spinbuttons (`type="number"`) — use `fill('')` then `type('value')` to simulate clearing and retyping
- Survey forms use per-question auto-save, not a single submit button — confirm by observing progress bar changes
- Password / repeat-password cross-field validation triggers on blur
- Routes like `/reset-password?uid=X&token=Y` can be tested with fake params to verify client-side validation only
- Invite-only routes (`/coolset-signup`) cannot be tested without a valid token — mark as untestable

### If the browser is locked / in use
Ask the user to close the browser window, then retry. Do not attempt to force-kill the process.

---

## Phase 5 — Post the Test Report to Linear

After all scenarios are complete, post a full report as a new comment on the ticket.

Format:
```markdown
## 📋 Test Report — [Ticket Title]

**Build:** [staging URL]
**Date:** [today]
**Tester:** Claude (Playwright automation)

### Results

| ID | Scenario | Result | Notes |
|----|----------|--------|-------|
| P1 | [scenario] | ✅ PASS | [notes] |
| E1 | [scenario] | ❌ FAIL | [error / observation] |

### Summary
- **Passed:** X / Y
- **Failed:** X / Y
- **Skipped / Untestable:** X

### Failures Detail
For each ❌ FAIL, include:
- Root cause analysis (if identifiable from the error message or code)
- Suggested fix (if obvious from the diff / PR)
- Steps to reproduce

### Verdict
✅ Ready to merge — all scenarios pass.
OR
❌ Blocked — [N] failure(s) need resolution before merge.
```

---

## Phase 6 — Retest on a Fixed Build (if failures exist)

If the developer provides a new staging URL with a fix:

1. Navigate to the new URL
2. Run **only the previously failing scenarios** — do not re-run passing ones unless there is regression risk
3. Record new results
4. Post a short retest comment:

```markdown
## 🔁 Retest — [scenario ID(s)]

**New build:** [url]

| ID | Previous | New | Notes |
|----|----------|-----|-------|
| E1 | ❌ FAIL | ✅ PASS | [what changed] |

All failures resolved. ✅
```

---

## Quick Reference Checklist

- [ ] Ticket fetched and scope understood
- [ ] Staging URL identified (from ticket or user)
- [ ] Test plan written — all changed areas covered
- [ ] Untestable scenarios called out explicitly
- [ ] Test plan posted to Linear as a comment
- [ ] User confirmed they are logged in to staging
- [ ] All scenarios executed with PASS/FAIL recorded
- [ ] Screenshots taken for failures
- [ ] Full test report posted to Linear
- [ ] Retest performed on fixed build (if any failures)
- [ ] Retest comment posted to Linear
