---
name: deploy
description: Tag-based deployment to staging or production. Parses latest tags, increments suffix, and pushes the new tag for Cloud Build.
---

# Deploy via git tag

Deploy to staging or production by creating and pushing a git tag. Cloud Build picks up the tag automatically.

## Usage

```
/deploy
```

## Instructions

When invoked, follow these steps:

### 1. Ask for target environment

Ask the user:

> "Deploy to **staging** or **production**?"

### 2. Fetch latest tags

Get the most recent tags for the chosen environment:

```bash
git fetch --tags
git tag --sort=-v:refname | grep "^staging-\|^production-" | head -10
```

### 3. Parse and increment the tag

Tags follow the format: `<env>-<sprint>.<minor>.<patch>-<n>`

Examples:
- `staging-3.42.0-2` → next is `staging-3.42.0-3`
- `production-3.42.0-1` → next is `production-3.42.0-2`

**Rules:**
1. Filter tags for the chosen environment (`staging-` or `production-`)
2. Take the latest tag and parse the `-<n>` suffix
3. Increment `<n>` by 1
4. If no tags exist for the current sprint, ask the user for the sprint number (e.g., `3.42.0`)

### 4. Confirm with user

Show the proposed tag and ask for confirmation:

> "Proposed tag: `staging-3.42.0-3` — push it?"

### 5. Create and push the tag

```bash
git tag <tag>
git push origin <tag>
```

### 6. Report completion

> "Tag `staging-3.42.0-3` pushed — Cloud Build will pick it up."
