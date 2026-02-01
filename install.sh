#!/bin/bash
# Install Claude skills by creating symlinks to ~/.claude/skills/

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
FORCE=false

# Parse arguments
if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
    FORCE=true
fi

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"

# Link each skill
for skill in "$REPO_DIR/skills/"*/; do
    skill_name=$(basename "$skill")
    target="$SKILLS_DIR/$skill_name"

    # Check if target already exists
    if [ -L "$target" ]; then
        if [ "$FORCE" = true ]; then
            rm "$target"
        else
            echo "Skipping $skill_name (symlink exists, use --force to update)"
            continue
        fi
    elif [ -e "$target" ]; then
        echo "Skipping $skill_name (directory exists at $target)"
        continue
    fi

    ln -s "$skill" "$target"
    echo "Linked $skill_name -> $target"
done

echo "Done! Skills are now available in Claude Code."
