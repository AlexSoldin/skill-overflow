---
name: create-agent
description: Interactive guide to create a new agent for any department in the marketplace.
---

# Create Agent

Interactively create a new agent for any department plugin in the skill-overflow marketplace.

## Instructions

Walk the user through creating a new agent, gathering details one at a time.

### 1. Gather details

Ask for each of the following, one at a time:

1. **Department**: Which plugin should this agent belong to? (shared, engineering, marketing, research, sales, customer-success)
2. **Agent name**: A kebab-case name (e.g., `code-reviewer`, `content-editor`). Validate it matches `^[a-z0-9]+(-[a-z0-9]+)*$`.
3. **Description**: A description of what the agent does. Must include `<example>` blocks showing when the agent should be triggered. Help the user write 2-3 example interactions:
   ```
   <example>
   User: <what the user might say>
   Agent: <agent-name>
   </example>
   ```
4. **Model**: Which model to use (sonnet, haiku, opus). Default: sonnet.
5. **Color**: Display color (green, blue, red, yellow, cyan, magenta). Default: green.
6. **Tools**: Which tools the agent can use. Common sets:
   - Read-only: `["Read", "Grep", "Glob"]`
   - Read-write: `["Read", "Bash", "Grep", "Glob", "Edit", "Write"]`
   - Full: `["Read", "Bash", "Grep", "Glob", "Edit", "Write", "WebFetch", "WebSearch"]`
7. **System prompt**: The instructions that define the agent's role and behavior. Help the user write a clear system prompt that includes:
   - The agent's role and expertise
   - How it should approach tasks
   - Output format expectations
   - Any guidelines or constraints

### 2. Generate agent file

Create the agent file at `<department>/agents/<agent-name>.md` with this structure:

```markdown
---
name: <agent-name>
description: |
  <description>

  <example>
  User: <example interaction>
  Agent: <agent-name>
  </example>
model: <model>
color: <color>
tools:
  - <tool1>
  - <tool2>
---

<system prompt>
```

### 3. Validate

Run the validation script:

```bash
python3 scripts/validate_plugin.py
```

If validation fails, fix the issues and re-validate.

### 4. Offer to commit

Ask the user if they'd like to commit and create a PR using `/shared:commit-push-pr`.

## Safety Rules

- Never overwrite an existing agent file without explicitly asking the user first
- Validate that the agent name is kebab-case before creating any files
- Always include at least 2 `<example>` blocks in the description
- Always run validation after generating the file
