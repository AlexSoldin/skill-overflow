# skill-overflow

A Claude Code plugin marketplace providing department-specific skills and agents for shared team workflows.

## Marketplace Structure

```
skill-overflow/
  .claude-plugin/
    marketplace.json          # Marketplace catalog (lists all plugins)
  shared/                     # Shared cross-team plugin
    .claude-plugin/plugin.json
    skills/
    agents/
  engineering/                # Engineering department plugin
  marketing/                  # Marketing department plugin
  research/                   # Research department plugin
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
/shared:commit-push-pr
/shared:refresh-plugin
```

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

## Adding Skills or Agents to a Department

### Skills

1. Create a directory under the department's `skills/`:

   ```
   mkdir engineering/skills/my-new-skill
   ```

2. Add a `SKILL.md` with YAML frontmatter:

   ```markdown
   ---
   name: my-new-skill
   description: Brief description of what the skill does.
   ---

   # My New Skill

   Instructions for Claude to follow when this skill is invoked.
   ```

### Agents

1. Create a markdown file under the department's `agents/`:

   ```markdown
   ---
   name: my-agent
   description: Brief description of what the agent does.
   ---

   # My Agent

   System prompt and instructions for the agent.
   ```

3. Commit and push — team members get the new skill/agent on their next plugin update.

## License

MIT License - see [LICENSE](LICENSE) for details.
