---
name: create-skill
description: Interactive guide to create a new skill for any department in the marketplace.
---

# Create Skill

Interactively create a new skill for any department plugin in the skill-overflow marketplace.

## Instructions

Walk the user through creating a new skill, gathering details one at a time.

### 1. Gather details

Ask for each of the following, one at a time. Suggest sensible defaults where possible.

1. **Department**: Which plugin should this skill belong to? (shared, engineering, marketing, research, sales, customer-success)
2. **Skill name**: A kebab-case name (e.g., `summarize-doc`, `draft-email`). Validate it matches `^[a-z0-9]+(-[a-z0-9]+)*$`.
3. **Description**: A one-line description for the frontmatter.
4. **Instructions**: Step-by-step instructions for Claude to follow when the skill is invoked. Help the user think through what tools Claude should use, what inputs to expect, and what output to produce.
5. **Safety rules** (optional): Any constraints or guardrails.

### 2. Generate SKILL.md

Create the skill file at `<department>/skills/<skill-name>/SKILL.md` with this structure:

```markdown
---
name: <skill-name>
description: <description>
---

# <Skill Title>

<description>

## Instructions

<instructions>

## Safety Rules

<safety-rules>
```

Omit the Safety Rules section if none were provided.

### 3. Validate

Run the validation script to ensure the skill is properly structured:

```bash
python3 scripts/validate_plugin.py
```

If validation fails, fix the issues and re-validate.

### 4. Offer to commit

Ask the user if they'd like to commit and create a PR using `/shared:commit-push-pr`.

## Safety Rules

- Never overwrite an existing SKILL.md without explicitly asking the user first
- Validate that the skill name is kebab-case before creating any files
- Always run validation after generating the file
