# Claude, Codex, and Cursor Skills/Rules

A collection of custom skills for [Claude Code](https://claude.com/claude-code), [Codex](https://openai.com/codex), and rules for [Cursor](https://cursor.com).

## What's the Difference?

| Aspect | Claude Skills | Codex Skills | Cursor Rules |
|--------|---------------|--------------|--------------|
| Location | `~/.claude/skills/` | `$CODEX_HOME/skills/` (defaults to `~/.codex/skills/`) | `~/.cursor/rules/` |
| Format | `SKILL.md` with YAML frontmatter | `SKILL.md` with YAML frontmatter | `.mdc` markdown files |
| Invocation | Slash commands (`/skill-name`) | Slash commands (`/skill-name`) | Auto-applied or manually referenced |
| Structure | Directory per skill | Directory per skill | Single file per rule |

**Skills** are explicitly invoked via slash commands in Claude Code and Codex. **Rules** provide contextual guidance that Cursor can apply automatically or that you reference in prompts.

## Available Skills & Rules

| Name | Description | Claude | Codex | Cursor |
|------|-------------|--------|-------|--------|
| commit-push-pr | Commit changes, push to remote, and create a PR. Enforces branch protection. | ✓ | ✓ | ✓ |
| refresh-claude-skills | Pull latest changes and reinstall Claude skills. | ✓ | — | — |
| refresh-codex-skills | Pull latest changes and reinstall Codex skills. | — | ✓ | — |
| refresh-cursor-rules | Pull latest changes and reinstall Cursor rules. | — | — | ✓ |

## Installation

### Quick Install

Run the install script - it will prompt you to choose which tool(s) to install for:

```bash
./install.sh
```

You'll see:
```
Install for which tool?
1) Claude only
2) Codex only
3) Cursor only
4) Claude + Cursor
5) All (Recommended)
Choice [5]:
```

### Non-Interactive Install

Use flags to skip the prompt:

```bash
./install.sh --claude    # Install Claude skills only
./install.sh --codex     # Install Codex skills only
./install.sh --cursor    # Install Cursor rules only
./install.sh --all       # Install Claude + Codex + Cursor (same as default)
```

### Flags

```bash
--claude    Install Claude skills only
--codex     Install Codex skills only
--cursor    Install Cursor rules only
--all       Install Claude + Codex + Cursor (default when no tool is specified)
--force     Replace existing symlinks (never overwrites real directories/files)
--prune     Remove stale or non-targeted symlinks that point into this repo
--list      Show what would be installed (no changes)
```

Add `--force` to update existing symlinks:

```bash
./install.sh --force --claude --cursor
```

Add `--prune` to remove non-targeted or stale symlinks:

```bash
./install.sh --prune --codex
./install.sh --prune --all
```

List what would be installed:

```bash
./install.sh --list --all
./install.sh --list --codex
```

### Manual Install

**Claude skills:**
```bash
ln -sf /path/to/claude-skills/skills/commit-push-pr ~/.claude/skills/commit-push-pr
```

**Codex skills:**
```bash
ln -sf /path/to/claude-skills/skills/commit-push-pr ~/.codex/skills/commit-push-pr
```

**Cursor rules:**
```bash
ln -sf /path/to/claude-skills/cursor-rules/commit-push-pr.mdc ~/.cursor/rules/commit-push-pr.mdc
```

## Usage

### Claude Code

Invoke skills using slash commands:

```
/commit-push-pr
/refresh-claude-skills
```

### Codex

Invoke skills using slash commands:

```
/commit-push-pr
/refresh-codex-skills
```

### Cursor

Rules in `~/.cursor/rules/` can be:
1. **Referenced directly** - Cursor can access rules from this global location
2. **Symlinked to projects** - Create project-specific symlinks:
   ```bash
   ln -sf ~/.cursor/rules/commit-push-pr.mdc /path/to/project/.cursor/rules/
   ```

## Creating New Skills/Rules

### Claude Skill

1. Create a directory under `skills/`:
   ```bash
   mkdir skills/my-new-skill
   ```

2. Create a `SKILL.md` file with YAML frontmatter:
   ```markdown
   ---
   name: my-new-skill
   description: Brief description of what the skill does
   allowed-tools: Bash, Read, Write
   ---

   # My New Skill

   Instructions for Claude to follow when this skill is invoked.
   ```

3. Run `./install.sh --claude` to create the symlink

### Codex Skill

1. Create a directory under `skills/`:
   ```bash
   mkdir skills/my-new-skill
   ```

2. Create a `SKILL.md` file with YAML frontmatter, including `targets`:
   ```markdown
   ---
   name: my-new-skill
   description: Brief description of what the skill does
   allowed-tools: Bash, Read, Write
   targets: [codex]
   ---

   # My New Skill

   Instructions for Codex to follow when this skill is invoked.
   ```

3. Run `./install.sh --codex` to create the symlink

### Cursor Rule

1. Create a `.mdc` file under `cursor-rules/`:
   ```bash
   touch cursor-rules/my-new-rule.mdc
   ```

2. Add markdown content (no frontmatter needed):
   ```markdown
   # My New Rule

   When asked to do X, follow these instructions...
   ```

3. Run `./install.sh --cursor` to create the symlink

## License

MIT License - see [LICENSE](LICENSE) for details.
