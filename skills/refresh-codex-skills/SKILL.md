---
name: refresh-codex-skills
description: Update Codex skills from the claude-skills repository by pulling latest changes and running the install script.
allowed-tools: Bash, Read
targets: [codex]
---

# Refresh Codex Skills

Update your Codex skills from the [claude-skills repository](https://github.com/AlexSoldin/claude-skills) by pulling the latest changes and running the install script.

## Usage

```
/refresh-codex-skills
```

## Instructions

When invoked, follow these steps:

### 1. Find and navigate to the repository

Locate the claude-skills repository by following a symlink from `~/.codex/skills`:

```bash
# Find the repo by following the refresh-codex-skills symlink
SKILL_LINK=$(readlink ~/.codex/skills/refresh-codex-skills)
REPO_DIR=$(dirname "$(dirname "$SKILL_LINK")")
echo "Found repository at: $REPO_DIR"
cd "$REPO_DIR"
```

If the symlink doesn't exist or isn't valid, inform the user they need to clone the repository first.

### 2. Check current state

Show the user what's currently installed:

```bash
echo "=== Current skills in repository ==="
ls -1 skills/

echo ""
echo "=== Current symlinks in ~/.codex/skills ==="
ls -la ~/.codex/skills/ | grep -E "^l"

echo ""
echo "=== Git status ==="
git status --short
```

### 3. Pull latest changes

Fetch and pull the latest changes from the remote repository:

```bash
git fetch origin
git pull origin main
```

Report what changed (if anything):
- If there were updates, show a summary of the changes
- If already up to date, inform the user

### 4. Run the install script

Run the install script with the `--force` flag to update existing symlinks:

```bash
./install.sh --force --codex
```

### 5. Verify installation

Confirm the skills are properly linked:

```bash
echo "=== Installed skills ==="
for skill in skills/*/; do
    skill_name=$(basename "$skill")
    target="$HOME/.codex/skills/$skill_name"
    if [ -L "$target" ]; then
        echo "✓ $skill_name"
    else
        echo "✗ $skill_name (not linked)"
    fi
done
```

### 6. Report completion

Provide a summary to the user:
- Number of skills updated/installed
- Any new skills that were added
- Any errors encountered

## Notes

- This skill finds the repository by following the symlink from `~/.codex/skills/refresh-codex-skills`
- Use `--force` to ensure symlinks are updated even if they already exist
- Existing user skills (non-symlinked directories) are never overwritten
