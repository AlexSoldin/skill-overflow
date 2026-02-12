# Contributing to skill-overflow

This guide covers how to contribute skills, agents, commands, hooks, and MCP servers to the marketplace.

## Two Ways to Contribute

### Option 1: GitHub Issue Form (no code required)

1. Go to **Issues > New Issue > New Skill Request**
2. Fill in the form fields: skill name, department, description, and instructions
3. A GitHub Action will automatically generate the skill file and open a pull request
4. A maintainer will review and merge it

This is the easiest path — you don't need to clone the repo or use Claude Code.

### Option 2: Claude Code `/create-skill` (interactive)

If you have Claude Code installed with the skill-overflow plugin:

```
/shared:create-skill
```

Claude will walk you through the process interactively, generate the file, run validation, and offer to open a PR.

## Writing Skills

Skills are slash commands that users invoke directly (e.g., `/shared:create-skill`).

**Location:** `<department>/skills/<skill-name>/SKILL.md`

**Required frontmatter:**

```yaml
---
name: my-skill-name        # Must match directory name, kebab-case
description: One-line description of what the skill does.
---
```

**Guidelines:**

- Write instructions FOR Claude, not for the user. Claude is the one executing the skill.
- Be specific about what tools to use (`Read`, `Bash`, `Grep`, etc.) and what output to produce.
- Use numbered steps for sequential workflows.
- Include a "Safety Rules" section for any constraints or guardrails.
- Gather information from the user one question at a time to avoid overwhelming them.

## Writing Agents

Agents are autonomous sub-agents that Claude routes to based on context.

**Location:** `<department>/agents/<agent-name>.md`

**Required frontmatter:**

```yaml
---
name: my-agent
description: |
  Description of what the agent does.

  <example>
  User: Example of what a user might say
  Agent: my-agent
  </example>

  <example>
  User: Another example interaction
  Agent: my-agent
  </example>
model: sonnet              # sonnet, haiku, or opus
color: green               # green, blue, red, yellow, cyan, magenta
tools:
  - Read
  - Bash
  - Grep
  - Glob
---
```

**Guidelines:**

- Include at least 2 `<example>` blocks in the description — these are how Claude decides when to route to the agent.
- The body (after frontmatter) is the agent's system prompt.
- Define the agent's role, approach, and output format clearly.
- Only grant the tools the agent actually needs.

## Writing Commands

Commands are slash commands with explicit model and tool constraints.

**Location:** `<department>/commands/<command-name>.md`

**Required frontmatter:**

```yaml
---
description: One-line description of what the command does
allowed-tools:             # Tools this command can use
  - Read
  - Bash
model: sonnet              # Model to use
argument-hint: "[args]"    # Optional hint shown to users
---
```

**Guidelines:**

- The body is instructions for Claude, not the user.
- Commands differ from skills in that they constrain which model and tools are used.
- Use `argument-hint` to tell users what arguments the command accepts.

## Writing Hooks

Hooks are event-driven automations that run in response to Claude Code events.

**Location:** `<department>/hooks/hooks.json`

**Structure:**

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "*",
        "type": "prompt",
        "prompt": "Instructions for Claude when this event fires."
      }
    ]
  }
}
```

**Available events:**

| Event | When it fires |
|-------|---------------|
| `PreToolUse` | Before Claude uses a tool |
| `PostToolUse` | After Claude uses a tool |
| `Stop` | When Claude is about to finish responding |
| `SubagentStop` | When a sub-agent is about to finish |
| `UserPromptSubmit` | When the user submits a prompt |
| `SessionStart` | When a new session begins |
| `SessionEnd` | When a session ends |
| `PreCompact` | Before context compression |
| `Notification` | When a notification is triggered |

**Hook types:**

- `"type": "prompt"` — Claude evaluates the prompt and decides what to do (recommended)
- `"type": "command"` — Runs a shell command directly

**Guidelines:**

- Use `"matcher": "*"` to match all tool calls, or a specific tool name to target one tool.
- Prompt-based hooks are safer and more flexible than command hooks.
- Keep prompts concise — they run on every matching event.

## Adding MCP Servers

MCP (Model Context Protocol) servers give Claude access to external tools and services.

**Location:** `<department>/.mcp.json`

**Two server types:**

```json
{
  "stdio-server": {
    "command": "npx",
    "args": ["-y", "some-mcp-package"],
    "env": {
      "API_KEY": "${API_KEY}"
    }
  },
  "http-server": {
    "type": "http",
    "url": "https://example.com/mcp"
  }
}
```

**Guidelines:**

- Use `${ENV_VAR}` syntax for secrets — never hardcode API keys or tokens.
- Prefer `http` type for hosted services (Linear, Sentry) and `stdio` for local tools (n8n, context7).
- Document required environment variables in the plugin's README or the root README.
- Use `/shared:register-mcp` to add servers interactively.

## Testing Your Contribution

Before submitting, run the validation script to verify your files are properly structured:

```bash
python3 scripts/validate_plugin.py
```

This validates:

- Marketplace and plugin JSON structure
- Skill frontmatter (name, description)
- Agent frontmatter (name, description, including multiline blocks)
- Command frontmatter (description)
- MCP server configs (command or type+url)
- Hook configs (valid event names, list structure)

All checks must pass before a PR can be merged.
