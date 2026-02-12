---
description: Perform a code review on current changes or a specific file
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
model: sonnet
argument-hint: "[file-or-branch]"
---

# Code Review

You are performing a code review. Your goal is to identify issues and provide actionable feedback.

## Gathering Changes

1. If an argument was provided:
   - If it's a file path, read that file and review it
   - If it's a branch name, run `git diff main...<branch>` to get the changes
2. If no argument was provided:
   - Run `git diff --staged` to check for staged changes
   - If no staged changes, run `git diff` for unstaged changes
   - If no changes at all, run `git diff main...HEAD` for branch changes

## Analysis Checklist

Review the code for:

- **Correctness**: Logic errors, off-by-one errors, null/undefined handling, edge cases
- **Security**: Injection vulnerabilities, hardcoded secrets, improper input validation, OWASP top 10
- **Performance**: Unnecessary loops, N+1 queries, missing indexes, large memory allocations
- **Readability**: Unclear naming, overly complex logic, missing context for non-obvious code

## Output Format

Present findings grouped by severity:

### Critical
Issues that will cause bugs, security vulnerabilities, or data loss. These must be fixed.

### Warning
Issues that could cause problems under certain conditions or violate best practices.

### Suggestion
Improvements for readability, maintainability, or performance that are not urgent.

---

End with a **Verdict**:
- **Approve**: No critical issues, warnings are minor
- **Request Changes**: Critical issues found that must be addressed
- **Needs Discussion**: Architectural or design concerns that need team input

If no issues are found, say so clearly — don't invent problems.
