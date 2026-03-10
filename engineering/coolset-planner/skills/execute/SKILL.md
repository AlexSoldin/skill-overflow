---
name: execute
description: >-
  Fetches the approved implementation plan for the current branch's Linear
  ticket and executes it step by step. Infers the ticket ID from the branch
  name, reads the AI section of the Linear description, and works through the
  plan using superpowers:executing-plans. Use when a plan has been reviewed and
  approved and you're ready to implement.
disable-model-invocation: true
---

# Coolset Execution Workflow

You are an execution agent for the Coolset platform. Your job is to fetch an approved implementation plan from Linear and implement it.

**Announce at start:** "I'm using the execute skill to fetch and implement the plan for this ticket."

## Step 1: Identify the Ticket

Infer the Linear ticket ID from the current git branch:

```bash
git branch --show-current
```

Branch names follow the format `cs-{number}-{description}`. Extract the ticket ID as `CS-{number}` (uppercase).

Examples:
- `cs-6565-no-error-when-adding-existing-origin-name` → `CS-6565`
- `cs-1234-add-new-feature` → `CS-1234`

If the branch name doesn't match this pattern, ask the user for the ticket ID.

## Step 2: Fetch the Plan from Linear

Use `ToolSearch` to load Linear tools, then fetch the issue:

```
mcp__claude_ai_Linear__get_issue({ id: "CS-XXXX" })
```

The issue description contains two sections separated by `---`:
- **Above the separator**: Human-readable background, diagrams, affected repos table
- **Below the separator**: The AI implementation plan (this is what you execute)

Extract the full AI section (everything after `---` and the HTML comment line).

If the description has no `---` separator or no implementation plan section, tell the user the plan doesn't appear to have been written yet and suggest running `/plan` first.

## Step 3: Identify Current Repo Scope

Check which repo you're currently in:

```bash
basename $(git rev-parse --show-toplevel)
```

If the plan covers **multiple repos**, filter to only the steps relevant to the current repo. Tell the user:

> "This plan covers multiple repos. I'll implement the steps for `{repo-name}` in this session. Steps for other repos will need separate sessions."

If the plan covers **only the current repo**, proceed with all steps.

## Step 4: Confirm Before Starting

Present the user with:
1. The ticket title and a one-line summary of what you're about to implement
2. The number of implementation steps
3. Which repo scope applies (if multi-repo)

Ask: "Ready to start implementation?"

Do not proceed until confirmed.

## Step 5: Execute the Plan

Use the `superpowers:executing-plans` skill to work through the implementation steps.

Key execution rules:
- Follow the plan's file paths exactly — they were verified during exploration
- Follow the referenced patterns (the plan cites existing files to model code after — read them before implementing)
- Write tests before or alongside implementation (the plan's test strategy section guides this)
- Run tests after each logical unit of work: `pnpm test -- --run path/to/file.test.ts`
- Commit after each completed step using conventional commits: `fix(CS-XXXX): description` or `feat(CS-XXXX): description`
- If you discover the plan is wrong or stale (file moved, pattern changed), pause and tell the user before continuing

## Step 6: In-Session Summary

When all steps are complete, present a structured summary:

```
## Implementation Complete — CS-XXXX

**What was done:**
- [bullet per major change]

**Files changed:**
- [list with one-line description each]

**Tests:**
- [x passed / any skipped]

**Commits:**
- [list of commit messages]

**Next steps:**
- Run /commit-push-pr to push and open the PR
- [any manual steps the plan flagged, e.g. migrations, env vars]
```

Ask the user if they want to review anything before pushing.
