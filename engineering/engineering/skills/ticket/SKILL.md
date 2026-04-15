---
name: ticket
description: Execute a Linear ticket end-to-end — read ticket, create worktree, implement, test, lint, commit, PR, assign reviewers, and post to Slack.
args: issue_id
---

# Linear ticket to PR

Execute a Linear ticket from start to finish. Read the ticket, implement the changes, and deliver a ready-to-review PR.

## Usage

```
/ticket CS-1234
```

## Instructions

When invoked with a ticket ID (e.g., `CS-1234`), follow these steps:

### 1. Read the Linear ticket

Fetch the ticket using the Linear MCP tool:

```
mcp__plugin_linear_linear__get_issue(id: "<issue_id>")
```

Extract:
- Title and description
- Acceptance criteria
- Any linked issues or parent tickets

Present a brief summary to the user and confirm the approach before proceeding.

### 2. Create a worktree

Create an isolated worktree using Worktrunk so work can happen in parallel without affecting the main workspace:

```bash
wt switch --create <issue_id>/<description-slug>
```

Branch name format: `CS-1234/short-description-slug` (lowercase, hyphens). The worktree is named the same as the branch.

All subsequent steps (implementation, tests, lint, commit) happen inside this worktree. Once the PR is merged, clean up with:

```bash
wt remove <issue_id>/<description-slug>
```

### 3. Implement changes

Implement the changes described in the ticket:
- Follow the project's code patterns and conventions (check `CLAUDE.md`)
- Write tests alongside the implementation
- Use the repository pattern for database queries
- Use services for business logic

### 4. Run tests

```bash
make tests
```

If tests fail, fix the issues and re-run until green. Do not proceed with failing tests.

### 5. Lint and format

```bash
ruff check . --fix --extend-select=I
ruff format .
```

### 6. Commit, push, and create PR

Invoke the `/commit-push-pr` skill to:
- Commit with conventional commit format referencing the ticket
- Push and create PR
- Detect and label migrations on the Linear ticket

### 7. Request review

Invoke the `/request-review` skill to:
- Assign reviewers based on the repo type
- Post a review request to #team-engineering on Slack
