---
name: commit-push-pr
description: Commit staged changes, push to remote, and create a pull request. Never pushes directly to main - always creates a new branch if on main.
---

# Commit, push, and create PR

Commit your changes, push to a remote branch, and create a pull request. This skill enforces branch protection by never pushing directly to main.

## Usage

```
/commit-push-pr
```

## Instructions

When invoked, follow these steps:

### 1. Check current branch and status

Run these commands to understand the current state:

```bash
git branch --show-current
git status
git diff --staged
git log --oneline -5
```

### 2. Handle main branch protection

**CRITICAL: Never push directly to main.**

If the current branch is `main` or `master`:
1. Ask the user for a branch name, suggesting one based on the staged changes
2. Create and checkout the new branch: `git checkout -b <branch-name>`
3. Continue with the commit process

If already on a feature branch, proceed to step 3.

### 3. Create the commit

1. Review the staged changes to understand what's being committed
2. Stage relevant files with `git add` if needed
3. Generate a commit message following Commitizen conventional commit format:
   - Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
   - Format: `<type>(<scope>): <description>` or `<type>: <description>`
   - All lowercase, max 100 chars for first line
   - Optional scope in parentheses (e.g., "feat(auth): add login")
   - Optional body for detailed explanation
   - Optional breaking changes footer
   - Examples:
     - "feat(user-auth): add user authentication"
     - "fix(nav): resolve navigation bug on mobile"
     - "refactor(contact): simplify form validation"
4. Create the commit using a HEREDOC for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<optional body>

EOF
)"
```

### 4. Push to remote

Push the branch to origin with upstream tracking:

```bash
git push -u origin <branch-name>
```

### 5. Create the pull request

Use the GitHub CLI to create a PR:

```bash
gh pr create --title "<type>(<scope>): <description>" --body "$(cat <<'EOF'
## Summary
- Brief description of changes

- Any Linear or Sentry issue number associated
EOF
)"
```

### 6. Suggest and assign reviewers

After the PR is created, suggest reviewers based on the repository name.

**Determine repo type from the GitHub remote origin:**

| Type | Repositories |
|------|-------------|
| **BE** | `cs-api`, `data-room-api`, `cloud-functions`, `cs-pulse`, `cs-scranton`, `cs-common`, `terraform` |
| **FE** | `coolset-react-app`, `data-room-package`, `cs-ui`, `data-room-react-app` |

**Reviewer pool (exclude the PR author):**

| GitHub Username | Name                  | Type |
|-----------------|-----------------------|------|
| `machadojoy`    | Joy Machado           | BE   |
| `Sigularusrex`  | David Sigley          | BE   |
| `AlexSoldin`    | Alex Soldin           | BE   |
| `adapass182`    | Adam Passingham       | FE   |
| `vvruspat`      | Alexander Kolesov     | FE   |

**Steps:**

1. Get the repo name from `gh repo view --json name -q .name`
2. Get the current GitHub user with `gh api user -q .login` to exclude them from reviewers
3. Match the repo name to the table above to determine BE or FE
4. If the repo doesn't match either list, ask the user whether it's BE or FE
5. Present the suggested reviewers to the user for confirmation
6. After the user confirms, assign them:

```bash
gh pr edit <pr-number> --add-reviewer <username1>,<username2>
```

### 7. Post review request to Slack

After assigning reviewers, post a message to the **#dev** Slack channel (`C04HM8SMMLJ`) requesting a review.

**Steps:**

1. Get the Linear issue ID from the branch name or PR body (e.g., `CS-1234`)
2. If a Linear issue is associated, fetch the issue details using the Linear MCP tool (`get_issue`) to get the title and URL
3. Send a Slack message using `mcp__claude_ai_Slack__slack_send_message` with:
   - **channel_id**: `C04HM8SMMLJ`
   - Tag the assigned reviewers using their Slack IDs
   - Include the Linear issue title, Linear URL, and PR URL

**Slack user ID mapping:**

| GitHub Username | Slack ID      |
|-----------------|---------------|
| `adapass182`    | `U05QRRHVCQM` |
| `AlexSoldin`    | `U04S7M5A2PM` |
| `machadojoy`    | `U0A09M3LLBH` |
| `Sigularusrex`  | `U0617K4NGCU` |
| `vvruspat`      | `U0A0UMK1JQ4` |

**Message format:**

```
Hey <@SLACK_ID1> <@SLACK_ID2> — could you review this PR? 🙏

*CS-XXXX — <Linear issue title>*
PR: <github PR URL>
Linear: <linear issue URL>
```

If no Linear issue is found, omit the Linear line and just include the PR URL and a summary of the changes.

### 8. Report completion

After creating the PR, provide:
- The PR URL
- A brief summary of what was committed
- The branch name used
- The assigned reviewers
- Confirmation that the Slack message was sent

## Safety rules

- **Never push to main/master** - always create a feature branch first
- **Never use --force** unless explicitly requested by the user
- **Never skip hooks** (--no-verify) unless explicitly requested
- **Never amend commits** that have been pushed to remote
- If there are no staged changes, inform the user and ask them to stage changes first
- If pre-commit hooks fail, fix the issues and create a new commit (don't amend)
- Ask the user which branch to target for the PR (default: main)
