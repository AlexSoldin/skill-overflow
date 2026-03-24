---
name: ticket
description: Execute a Linear ticket end-to-end — read ticket, create branch, implement, test, lint, commit, PR, assign reviewers, post to Slack, and offer deployment.
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

### 2. Create a branch

```bash
git checkout main
git pull origin main
git checkout -b <issue_id>/<description-slug>
```

Branch name format: `CS-1234/short-description-slug` (lowercase, hyphens).

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

### 6. Commit, push, PR, reviewers, Slack, and deploy

Invoke the `/commit-push-pr` skill to handle the rest of the workflow:
- Commit with conventional commit format referencing the ticket
- Push and create PR
- Suggest and assign reviewers
- Post review request to `#team-engineering` on Slack
- Offer deployment to staging
