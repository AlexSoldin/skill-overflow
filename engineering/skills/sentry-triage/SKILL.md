---
name: sentry-triage
description: >-
  This skill should be used when the user asks to "fix sentry errors",
  "triage sentry issues", "fix production bugs from sentry",
  "find and fix top errors", "resolve sentry issues in the codebase",
  or wants to proactively fix the most impactful errors reported by Sentry.
---

# Sentry Triage

Proactively fetch the most impactful production errors from Sentry, analyze their stack traces, and autonomously fix them in the codebase.

## Usage

```
/sentry-triage
```

## Instructions

When invoked, follow these steps:

### 1. Identify the Sentry project

Auto-detect the project from the git remote:

```bash
git remote get-url origin
```

Extract the org and repo name from the remote URL. Use the Sentry MCP tools to list available projects and match against the repo name.

If auto-detection fails or multiple projects match, ask the user to pick the correct Sentry project.

### 2. Fetch and prioritize issues

Use Sentry MCP tools to fetch **unresolved** issues for the project, sorted by frequency and user impact.

Present a summary table of the top 10 issues:

```
| #  | Title                          | Events | Users | Level | Last Seen   |
|----|--------------------------------|--------|-------|-------|-------------|
| 1  | TypeError: Cannot read ...     | 1,234  | 892   | error | 2 hours ago |
| 2  | ...                            | ...    | ...   | ...   | ...         |
```

Then ask the user one question: **"Proceed with all, pick specific issues (e.g. 1,3,5), or top N?"**

Default to all if the user just confirms.

### 3. Analyze and fix each issue

For each selected issue, run through this loop:

#### 3a. Fetch the latest event and stack trace

Use Sentry MCP tools to get the latest event for the issue, including the full stack trace.

#### 3b. Filter to local code frames

From the stack trace, discard frames that originate from:
- `node_modules/`
- `vendor/`
- Third-party libraries or framework internals
- Any path outside the current repository

Keep only frames pointing to code in this project.

#### 3c. Map stack trace paths to local files

Stack trace paths often include deployment prefixes (e.g. `/app/`, `/var/task/`, `/home/runner/`). Strip these prefixes and use **Glob** to verify the file exists locally.

For example:
- `/app/src/handlers/api.ts:42` -> Glob for `**/src/handlers/api.ts`, then read around line 42

If a file cannot be found locally, skip that frame and note it in the summary.

#### 3d. Read and analyze the relevant code

Read the matched local files around the error location. Analyze:
- What the code is doing at the point of failure
- What input conditions trigger the error
- Whether the error is a symptom of a deeper issue

#### 3e. Apply the fix

**High-confidence fixes** -- apply silently:
- Null/undefined checks for property access on nullable values
- Missing guard clauses or early returns
- Unhandled promise rejections or missing try/catch
- Off-by-one errors visible from the stack trace
- Missing default cases in switch statements
- Type coercion issues (e.g. `.toString()` on null)

**Low-confidence fixes** -- ask the user before applying:
- Architectural issues (wrong data flow, missing abstraction)
- Race conditions or concurrency bugs
- Issues requiring changes across multiple modules
- Problems where the root cause is ambiguous
- Anything requiring new dependencies or significant refactoring

Make **minimal, targeted changes** -- fix the bug, don't refactor surrounding code.

#### 3f. Move to the next issue

After fixing (or skipping) an issue, move to the next selected issue.

### 4. Summary report

After processing all issues, present a final summary:

```
## Sentry Triage Summary

### Fixes Applied
| Issue | Title | Fix Description |
|-------|-------|-----------------|
| PROJ-123 | TypeError: Cannot read... | Added null check before accessing user.profile.name |

### Issues Skipped
| Issue | Title | Reason |
|-------|-------|--------|
| PROJ-456 | Race condition in... | Low confidence -- requires architectural review |

### Next Steps
- Run your test suite to verify the fixes
- Use `/engineering:commit-push-pr` to commit and open a PR
- Review skipped issues manually or re-run with guidance
```

## Safety rules

- **Never commit automatically** -- only apply code changes, let the user commit when ready
- **Minimal changes only** -- fix the specific bug, do not refactor or improve surrounding code
- **Skip third-party code** -- never modify files in node_modules, vendor, or other dependency directories
- **Ask when uncertain** -- if a fix is ambiguous or could have unintended side effects, ask before applying
- **Preserve existing behavior** -- fixes should not change the intended behavior of the code, only prevent the error
- **One fix per issue** -- do not bundle unrelated changes together
