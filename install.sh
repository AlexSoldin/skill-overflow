#!/bin/bash
# Install Claude skills and/or Cursor rules by creating symlinks

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/install/lib/config.sh"
source "$SCRIPT_DIR/install/lib/args.sh"
source "$SCRIPT_DIR/install/lib/util.sh"
source "$SCRIPT_DIR/install/lib/skills.sh"
source "$SCRIPT_DIR/install/lib/cursor.sh"
source "$SCRIPT_DIR/install/lib/prune.sh"
source "$SCRIPT_DIR/install/lib/install_skills.sh"

parse_args "$@"
prompt_for_targets

if [ "$LIST_ONLY" = true ]; then
    echo "Listing installable items from $REPO_DIR"
    [ "$INSTALL_CLAUDE" = true ] && list_skills "claude" "Claude skills"
    [ "$INSTALL_CODEX" = true ] && list_skills "codex" "Codex skills"
    [ "$INSTALL_CURSOR" = true ] && list_cursor_rules
    echo ""
    exit 0
fi

if [ "$PRUNE" = true ]; then
    [ "$INSTALL_CLAUDE" = true ] && prune_skill_links "claude" "$CLAUDE_SKILLS_DIR"
    [ "$INSTALL_CODEX" = true ] && prune_skill_links "codex" "$CODEX_SKILLS_DIR"
    [ "$INSTALL_CURSOR" = true ] && prune_cursor_links "$CURSOR_RULES_DIR"
fi

[ "$INSTALL_CLAUDE" = true ] && install_skill_links "claude" "$CLAUDE_SKILLS_DIR" "Claude skills"
[ "$INSTALL_CODEX" = true ] && install_skill_links "codex" "$CODEX_SKILLS_DIR" "Codex skills"
[ "$INSTALL_CURSOR" = true ] && install_cursor_rules

echo ""
echo "Done!"
[ "$INSTALL_CLAUDE" = true ] && echo "Claude skills are now available in Claude Code."
[ "$INSTALL_CODEX" = true ] && echo "Codex skills are now available in $CODEX_SKILLS_DIR."
[ "$INSTALL_CURSOR" = true ] && echo "Cursor rules are now available in ~/.cursor/rules/"
exit 0
