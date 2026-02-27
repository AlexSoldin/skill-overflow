# skill-overflow

A Claude Code plugin marketplace providing department-specific skills and agents for shared team workflows.

## Marketplace Structure

```
skill-overflow/
  .claude-plugin/
    marketplace.json          # Marketplace catalog (lists all plugins)
  shared/
    shared/                   # Shared cross-team plugin
      .claude-plugin/plugin.json
      .mcp.json               # MCP servers (n8n)
      skills/
        refresh-plugin/       # Update installed plugins
        submit-skill/         # Submit a new skill via pull request
      agents/
  engineering/
    engineering/              # Engineering department plugin
      .claude-plugin/plugin.json
      .mcp.json               # MCP servers (Linear)
      skills/
        commit-push-pr/       # Commit, push, and create a PR
        sentry-triage/        # Triage and fix Sentry errors
        component-dev/        # Build new cs-ui components from Figma
      agents/
      commands/
      hooks/
  research/
    coolset-academy/          # Coolset Academy content writing plugin
      .claude-plugin/plugin.json
      skills/
        academy-writing/      # Write, optimize, and review Academy articles
      commands/
        write-article.md
        optimize-article.md
        review-article.md
```

Departments are organizational folders that contain one or more plugins. Empty departments are not included — they are created when a team submits their first real plugin.

## Available Plugins

| Plugin | Department | Category | Description |
|--------|------------|----------|-------------|
| `shared` | shared | productivity | Shared skills for commit workflows, plugin updates, and common team tooling. |
| `engineering` | engineering | development | Engineering department skills and agents for development workflows. |
| `coolset-academy` | research | content | Create, optimize, and review Coolset Academy articles with consistent voice, style, and AI discoverability. |
| `fe-unit-test-generator` | engineering | development | Generate comprehensive unit tests for React/TypeScript components, hooks, and utilities using Vitest and @testing-library/react. |

## Installation

Add the marketplace, then install the plugins relevant to your team:

```
/plugin marketplace add AlexSoldin/skill-overflow
/plugin install skill-overflow@shared
/plugin install skill-overflow@engineering
/plugin install skill-overflow@coolset-academy
/plugin install skill-overflow@fe-unit-test-generator
```

## Team-Wide Setup

To auto-configure plugins for all team projects, add to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "skill-overflow": {
      "source": { "source": "github", "repo": "AlexSoldin/skill-overflow" }
    }
  },
  "enabledPlugins": {
    "skill-overflow@shared": true,
    "skill-overflow@engineering": true,
    "skill-overflow@coolset-academy": true
  }
}
```

Add or remove plugins from `enabledPlugins` based on team needs.

## MCP Server Setup

Each plugin can include an `.mcp.json` file to register MCP (Model Context Protocol) servers. These provide Claude with access to external tools and services.

**Current MCP servers:**

| Plugin | Server | Type | Description |
|--------|--------|------|-------------|
| `shared` | n8n | stdio | Workflow automation via n8n |
| `engineering` | Linear | http | Issue tracking and project management |

**Environment variables:** Some MCP servers require environment variables. Set these in your shell or `.env` file:

| Variable | Used by | Description |
|----------|---------|-------------|
| `N8N_BASE_URL` | n8n | Your n8n instance URL |
| `N8N_API_KEY` | n8n | Your n8n API key |

## Updating

Update plugins to the latest version:

```
/plugin update skill-overflow@shared
```

Or use the built-in skill to update all installed plugins:

```
/shared:refresh-plugin
```

## Usage

Invoke skills using namespaced slash commands:

```
/shared:refresh-plugin                  # Update installed plugins
/shared:submit-skill                    # Submit a new skill via pull request
/engineering:commit-push-pr             # Commit, push, and create a PR
/engineering:sentry-triage              # Triage and fix Sentry errors
/engineering:component-dev              # Build new cs-ui components from Figma
/coolset-academy:academy-writing        # Write Coolset Academy content
/coolset-academy:write-article [topic]  # Write an article from a brief
/coolset-academy:optimize-article       # Optimize article for AI discoverability
/coolset-academy:review-article         # Review a draft against guidelines
/fe-unit-test-generator:generate [file] # Generate unit tests for a source file
```

## Versioning

When you add or change skills, agents, commands, or hooks in a plugin, bump the `version` field in that plugin's `plugin.json` and push to `main`. Users pick up changes by running `/shared:refresh-plugin` or `/plugin update skill-overflow@<plugin-name>`.

## Plugin Features Reference

| Feature | Location | Purpose |
|---------|----------|---------|
| Skills | `<department>/<plugin>/skills/<name>/SKILL.md` | Slash commands invoked by users |
| Agents | `<department>/<plugin>/agents/<name>.md` | Autonomous sub-agents triggered by context |
| Commands | `<department>/<plugin>/commands/<name>.md` | Slash commands with model/tool constraints |
| Hooks | `<department>/<plugin>/hooks/hooks.json` | Event-driven automation (pre/post tool use, stop, etc.) |
| MCP Servers | `<department>/<plugin>/.mcp.json` | External tool integrations via Model Context Protocol |

## Adding a New Plugin to an Existing Department

1. Create the directory structure under the department folder:

   ```
   mkdir -p research/my-plugin/.claude-plugin research/my-plugin/skills research/my-plugin/agents research/my-plugin/commands research/my-plugin/hooks
   ```

2. Add a `research/my-plugin/.claude-plugin/plugin.json`:

   ```json
   {
     "name": "my-plugin",
     "version": "1.0.0",
     "description": "My plugin description."
   }
   ```

3. Register it in `.claude-plugin/marketplace.json` under `plugins`:

   ```json
   {
     "name": "my-plugin",
     "source": "./research/my-plugin",
     "description": "My plugin description.",
     "category": "productivity",
     "department": "research"
   }
   ```

4. Commit and push — team members can install with `/plugin install skill-overflow@my-plugin`.

## Adding a New Department Plugin

1. Create a new department folder with a plugin subdirectory:

   ```
   mkdir -p new-department/my-plugin/.claude-plugin new-department/my-plugin/skills new-department/my-plugin/agents
   ```

2. Add a `new-department/my-plugin/.claude-plugin/plugin.json`:

   ```json
   {
     "name": "my-plugin",
     "version": "1.0.0",
     "description": "My department skills and agents."
   }
   ```

3. Register it in `.claude-plugin/marketplace.json` under `plugins`:

   ```json
   {
     "name": "my-plugin",
     "source": "./new-department/my-plugin",
     "description": "My department skills and agents.",
     "category": "productivity",
     "department": "new-department"
   }
   ```

4. Commit and push — team members can install with `/plugin install skill-overflow@my-plugin`.

## Adding Skills, Agents, Commands, and Hooks

Please utilise the plugin provided by Anthropic which assits with the creation of all of these elements.

### Skills

Create a directory under `skills/` with a `SKILL.md` containing YAML frontmatter and instructions:

```
mkdir -p engineering/engineering/skills/my-skill
```

```markdown
---
name: my-skill
description: Brief description of what the skill does.
---

# My Skill

Step-by-step instructions for Claude to follow when invoked.
```

### Agents

Create a markdown file under `agents/` with a name, description, and system prompt:

```markdown
---
name: my-agent
description: Brief description of when this agent should be used.
model: sonnet
tools:
  - Read
  - Bash
---

You are a specialist agent. Your role is to...
```

### Commands

Create a markdown file under `commands/` with a description and optional tool/model constraints:

```markdown
---
description: What this command does in one line.
allowed-tools:
  - Read
  - Grep
model: sonnet
argument-hint: "[optional-arg]"
---

# Command Name

Instructions for what Claude should do when this command is invoked.
```

### Hooks

Add entries to `hooks/hooks.json` to run prompts or commands on lifecycle events:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "type": "prompt",
        "prompt": "Reminder to display before finishing."
      }
    ]
  }
}
```

Supported events: `PreToolUse`, `PostToolUse`, `Notification`, `Stop`, `SubagentStop`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `PreCompact`.

## License

MIT License - see [LICENSE](LICENSE) for details.
