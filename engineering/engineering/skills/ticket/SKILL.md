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

### 6. Commit

Stage and commit using conventional commit format referencing the ticket:

```bash
git add <files>
git commit -m "$(cat <<'EOF'
<type>(<issue_id>): <description>

<optional body explaining the changes>

EOF
)"
```

### 7. Push and create PR

```bash
git push -u origin <branch-name>
```

Create the PR:

```bash
gh pr create --title "<type>(<issue_id>): <description>" --body "$(cat <<'EOF'
## Summary
- <bullet points describing changes>

## Linear
<linear issue URL>

## Test plan
- <how to verify the changes>
EOF
)"
```

### 8. Suggest and assign reviewers

Auto-detect BE/FE from the repo name and suggest reviewers.

**Repo type mapping:**

| Type | Repositories |
|------|-------------|
| **BE** | `cs-api`, `data-room-api`, `cloud-functions`, `cs-pulse`, `cs-scranton`, `cs-common`, `terraform` |
| **FE** | `coolset-react-app`, `data-room-package`, `cs-ui`, `data-room-react-app` |

**Reviewer pool (exclude the PR author):**

| GitHub Username | Name | Type | Slack ID |
|-----------------|------|------|----------|
| `machadojoy` | Joy Machado | BE | `U0A09M3LLBH` |
| `Sigularusrex` | David Sigley | BE | `U0617K4NGCU` |
| `AlexSoldin` | Alex Soldin | BE | `U04S7M5A2PM` |
| `adapass182` | Adam Passingham | FE | `U05QRRHVCQM` |
| `vvruspat` | Alexander Kolesov | FE | `U0A0UMK1JQ4` |

**Steps:**

1. Get the repo name: `gh repo view --json name -q .name`
2. Get the current user: `gh api user -q .login` (to exclude from reviewers)
3. Match repo to BE or FE from the table above
4. Present suggested reviewers to the user for confirmation
5. Assign them: `gh pr edit <pr-number> --add-reviewer <username1>,<username2>`

### 9. Post to Slack

Post a review request to the **#team-engineering** channel (`C04HM8SMMLJ`):

```
mcp__claude_ai_Slack__slack_send_message(
  channel_id: "C04HM8SMMLJ",
  text: "Hey <@SLACK_ID1> <@SLACK_ID2> — could you review this PR? 🙏\n\n*CS-XXXX — <Linear issue title>*\nPR: <github PR URL>\nLinear: <linear issue URL>"
)
```

### 10. Offer deployment

Ask the user:

> "Deploy to staging?"

If the user says yes, invoke the `/deploy` skill to trigger the staging deployment flow.
