---
name: commit-push-pr
description: Commit staged changes, push to remote, and create a pull request. Never pushes directly to main - always creates a new branch if on main.
allowed-tools: Bash, Read, Grep
targets: [claude, codex]
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
     - "feat: add user authentication"
     - "fix(nav): resolve navigation bug on mobile"
     - "refactor(contact): simplify form validation"
4. Create the commit using a HEREDOC for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<optional body>

Co-Authored-By: AI Assistant <noreply@local>
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

## Test plan
- [ ] Steps to test the changes

Generated with an AI assistant
EOF
)"
```

### 6. Report completion

After creating the PR, provide:
- The PR URL
- A brief summary of what was committed
- The branch name used

## Safety rules

- **Never push to main/master** - always create a feature branch first
- **Never use --force** unless explicitly requested by the user
- **Never skip hooks** (--no-verify) unless explicitly requested
- **Never amend commits** that have been pushed to remote
- If there are no staged changes, inform the user and ask them to stage changes first
- If pre-commit hooks fail, fix the issues and create a new commit (don't amend)
- Ask the user which branch to target for the PR (default: main)
