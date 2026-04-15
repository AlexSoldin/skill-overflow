---
name: request-review
description: Assign reviewers to a PR based on the repo type and post a review request to #team-engineering on Slack with Linear context.
args: "[PR number or URL]"
---

# Request review

Assign reviewers to a pull request and post a review request to Slack. Can be invoked standalone on any open PR or chained after `/commit-push-pr`.

## Usage

```
/request-review
/request-review 123
/request-review https://github.com/Coolset/cs-api/pull/123
```

## Instructions

When invoked, follow these steps:

### 1. Identify the PR

If a PR number or URL was passed as `$ARGUMENTS`, use it.

Otherwise, detect the PR from the current branch:

```bash
gh pr view --json number,url,title
```

If no open PR is found for the current branch, stop and inform the user. Do not proceed without a PR.

### 2. Suggest and assign reviewers

Suggest reviewers based on the repository name.

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

### 3. Post review request to Slack

Post a message to the **#team-engineering** Slack channel requesting a review.

**Steps:**

1. Get the branch name from `git branch --show-current`
2. Extract the Linear issue ID from the branch name or PR body (pattern: `CS-\d+`)
3. If a Linear issue is found, fetch the issue details using `mcp__plugin_linear_linear__get_issue` to get the title
4. Determine the change type from the branch name prefix:
   - `feat` → Feature
   - `fix` → Bug fix
   - `refactor` → Refactor
   - `chore` → Chore
   - If no prefix match, omit the change type from the header
5. Get the repo name from `gh repo view --json name -q .name`

**Slack user ID mapping:**

| GitHub Username | Slack ID      |
|-----------------|---------------|
| `adapass182`    | `U05QRRHVCQM` |
| `AlexSoldin`    | `U04S7M5A2PM` |
| `machadojoy`    | `U0A09M3LLBH` |
| `Sigularusrex`  | `U0617K4NGCU` |
| `vvruspat`      | `U0A0UMK1JQ4` |

**Send the message** using `mcp__claude_ai_Slack__slack_send_message` with **channel_id** `C04HM8SMMLJ`.

**Message format:**

```
:eyes: *Review request* · `<repo-name>` · <change-type>

<@SLACK_ID1> <@SLACK_ID2> — could you review this PR?

*CS-XXXX — <Linear issue title>*
<github PR URL|PR #number>
```

- If no Linear issue is found, use the PR title instead and omit the `CS-XXXX —` prefix
- If no change type is detected, omit `· <change-type>` from the header line

### 4. Report completion

Confirm:
- Which reviewers were assigned
- That the Slack message was sent to #team-engineering
- The PR URL

## Safety rules

- Never post to Slack without first confirming reviewers with the user
- If the PR has already been merged or closed, inform the user and stop
