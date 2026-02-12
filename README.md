# skill-overflow

A Claude Code plugin providing shared team skills for commit workflows, pre-commit management, and plugin updates.

## Available Skills

| Skill | Description |
|-------|-------------|
| `commit-push-pr` | Commit staged changes, push to remote, and create a PR. Enforces branch protection by never pushing directly to main. |
| `refresh-plugin` | Update the skill-overflow plugin to the latest version. |

## Installation

Add the marketplace and install the plugin:

```
/plugin marketplace add AlexSoldin/skill-overflow
/plugin install skill-overflow@skill-overflow
```

## Team-Wide Setup

To auto-configure the plugin for all team projects, add to `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "skill-overflow": {
      "source": { "source": "github", "repo": "AlexSoldin/skill-overflow" }
    }
  },
  "enabledPlugins": {
    "skill-overflow@skill-overflow": true
  }
}
```

## Updating

Update to the latest version:

```
/plugin update skill-overflow@skill-overflow
```

Or use the built-in skill:

```
/skill-overflow:refresh-plugin
```

## Usage

Invoke skills using namespaced slash commands:

```
/skill-overflow:commit-push-pr
/skill-overflow:refresh-plugin
```

## Creating New Skills

1. Create a directory under `skills/`:

   ```
   mkdir skills/my-new-skill
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

3. Commit and push — team members get the new skill on their next plugin update.

## License

MIT License - see [LICENSE](LICENSE) for details.
