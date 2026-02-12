# skill-overflow

A Claude Code plugin marketplace providing department-specific skills and agents for shared team workflows.

## Marketplace Structure

```
skill-overflow/
  .claude-plugin/
    marketplace.json          # Marketplace catalog (lists all plugins)
  shared/                     # Shared cross-team plugin
    .claude-plugin/plugin.json
    .mcp.json                 # MCP servers (n8n)
    skills/
      commit-push-pr/
      refresh-plugin/
      create-skill/           # Interactive skill creation
      register-mcp/           # MCP server registration
      create-agent/           # Interactive agent creation
    agents/
  engineering/                # Engineering department plugin
    .mcp.json                 # MCP servers (Linear)
    skills/
    agents/
      code-reviewer.md        # Code review agent
    commands/
      review.md               # /review slash command
    hooks/
      hooks.json              # Stop hook (test reminder)
  marketing/                  # Marketing department plugin
  research/                   # Research department plugin
    .mcp.json                 # MCP servers (Linear)
  sales/                      # Sales department plugin
  customer-success/           # Customer success department plugin
```

## Available Plugins

| Plugin | Category | Description |
|--------|----------|-------------|
| `shared` | productivity | Shared skills for commit workflows, plugin updates, and common team tooling. |
| `engineering` | development | Engineering department skills and agents for development workflows. |
| `marketing` | productivity | Marketing department skills and agents for content and campaign workflows. |
| `research` | productivity | Research department skills and agents for analysis and discovery workflows. |
| `sales` | productivity | Sales department skills and agents for pipeline and outreach workflows. |
| `customer-success` | productivity | Customer success department skills and agents for support and retention workflows. |

## Installation

Add the marketplace, then install the plugins relevant to your team:

```
/plugin marketplace add AlexSoldin/skill-overflow
/plugin install skill-overflow@shared
/plugin install skill-overflow@engineering
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
    "skill-overflow@engineering": true
  }
}
```

Add or remove department plugins from `enabledPlugins` based on team needs.

## MCP Server Setup

Each department plugin can include an `.mcp.json` file to register MCP (Model Context Protocol) servers. These provide Claude with access to external tools and services.

**Current MCP servers:**

| Plugin | Server | Type | Description |
|--------|--------|------|-------------|
| `shared` | n8n | stdio | Workflow automation via n8n |
| `engineering` | Linear | http | Issue tracking and project management |
| `research` | Linear | http | Issue tracking and project management |

**Environment variables:** Some MCP servers require environment variables. Set these in your shell or `.env` file:

| Variable | Used by | Description |
|----------|---------|-------------|
| `N8N_BASE_URL` | n8n | Your n8n instance URL |
| `N8N_API_KEY` | n8n | Your n8n API key |

To add a new MCP server, use the built-in skill:

```
/shared:register-mcp
```

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
/shared:commit-push-pr       # Commit, push, and create a PR
/shared:refresh-plugin        # Update installed plugins
/shared:create-skill          # Create a new skill interactively
/shared:register-mcp          # Register an MCP server
/shared:create-agent          # Create a new agent interactively
/engineering:review            # Run a code review (command)
```

## Contributing

There are two ways to contribute new skills — no coding experience required for either.

### Option 1: GitHub Issue Form (browser only)

1. Go to **Issues > New Issue > New Skill Request**
2. Fill in the form: skill name, department, description, instructions, and optional safety rules
3. A GitHub Action will automatically generate the skill file and open a PR

### Option 2: Claude Code Skill (interactive)

Run the create-skill command inside Claude Code:

```
/shared:create-skill
```

Claude will walk you through the process step by step and generate the file for you.

For more detailed contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Plugin Features Reference

| Feature | Location | Purpose |
|---------|----------|---------|
| Skills | `<plugin>/skills/<name>/SKILL.md` | Slash commands invoked by users |
| Agents | `<plugin>/agents/<name>.md` | Autonomous sub-agents triggered by context |
| Commands | `<plugin>/commands/<name>.md` | Slash commands with model/tool constraints |
| Hooks | `<plugin>/hooks/hooks.json` | Event-driven automation (pre/post tool use, stop, etc.) |
| MCP Servers | `<plugin>/.mcp.json` | External tool integrations via Model Context Protocol |

## Adding a New Department Plugin

1. Create the directory structure:

   ```
   mkdir -p my-department/.claude-plugin my-department/skills my-department/agents
   ```

2. Add a `my-department/.claude-plugin/plugin.json`:

   ```json
   {
     "name": "my-department",
     "version": "1.0.0",
     "description": "My department skills and agents."
   }
   ```

3. Register it in `.claude-plugin/marketplace.json` under `plugins`:

   ```json
   {
     "name": "my-department",
     "source": "./my-department",
     "description": "My department skills and agents.",
     "category": "productivity"
   }
   ```

4. Commit and push — team members can install with `/plugin install skill-overflow@my-department`.

## License

MIT License - see [LICENSE](LICENSE) for details.
