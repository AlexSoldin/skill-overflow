#!/bin/bash
# Install Claude skills and/or Cursor rules by creating symlinks

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CODEX_SKILLS_DIR="$CODEX_HOME/skills"
CURSOR_RULES_DIR="$HOME/.cursor/rules"
FORCE=false
INSTALL_CLAUDE=false
INSTALL_CODEX=false
INSTALL_CURSOR=false
LIST_ONLY=false
PRUNE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-f)
            FORCE=true
            shift
            ;;
        --claude)
            INSTALL_CLAUDE=true
            shift
            ;;
        --codex)
            INSTALL_CODEX=true
            shift
            ;;
        --cursor)
            INSTALL_CURSOR=true
            shift
            ;;
        --all)
            INSTALL_CLAUDE=true
            INSTALL_CODEX=true
            INSTALL_CURSOR=true
            shift
            ;;
        --list|-l)
            LIST_ONLY=true
            shift
            ;;
        --prune|-p)
            PRUNE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: ./install.sh [--force] [--list] [--prune] [--claude|--codex|--cursor|--all]"
            exit 1
            ;;
    esac
done

# If list-only and no tool specified, default to all
if [ "$LIST_ONLY" = true ] && [ "$INSTALL_CLAUDE" = false ] && [ "$INSTALL_CODEX" = false ] && [ "$INSTALL_CURSOR" = false ]; then
    INSTALL_CLAUDE=true
    INSTALL_CODEX=true
    INSTALL_CURSOR=true
fi

# If no tool specified, prompt interactively
if [ "$INSTALL_CLAUDE" = false ] && [ "$INSTALL_CODEX" = false ] && [ "$INSTALL_CURSOR" = false ]; then
    echo "Install for which tool?"
    echo "1) Claude only"
    echo "2) Codex only"
    echo "3) Cursor only"
    echo "4) Claude + Cursor"
    echo "5) All (Recommended)"
    read -p "Choice [5]: " choice
    choice=${choice:-5}

    case $choice in
        1)
            INSTALL_CLAUDE=true
            ;;
        2)
            INSTALL_CODEX=true
            ;;
        3)
            INSTALL_CURSOR=true
            ;;
        4)
            INSTALL_CLAUDE=true
            INSTALL_CURSOR=true
            ;;
        5|"")
            INSTALL_CLAUDE=true
            INSTALL_CODEX=true
            INSTALL_CURSOR=true
            ;;
        *)
            echo "Invalid choice. Defaulting to all."
            INSTALL_CLAUDE=true
            INSTALL_CODEX=true
            INSTALL_CURSOR=true
            ;;
    esac
fi

normalize_targets() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[]' | tr ',\"' ' ' | xargs
}

skill_targets() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [ ! -f "$skill_md" ]; then
        echo "all"
        return
    fi

    local in_front=false
    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            if [ "$in_front" = false ]; then
                in_front=true
                continue
            else
                break
            fi
        fi
        if [ "$in_front" = false ]; then
            continue
        fi
        if [[ "$line" == targets:* ]]; then
            local raw="${line#targets:}"
            raw="$(echo "$raw" | xargs)"
            if [ -z "$raw" ]; then
                echo "all"
            else
                echo "$raw"
            fi
            return
        fi
    done < "$skill_md"

    echo "all"
}

targets_include() {
    local targets_raw="$1"
    local tool="$2"
    local normalized
    normalized="$(normalize_targets "$targets_raw")"
    if [ -z "$normalized" ] || echo "$normalized" | grep -qw "all"; then
        return 0
    fi
    echo "$normalized" | grep -qw "$tool"
}

list_skills() {
    local tool="$1"
    local label="$2"
    echo ""
    echo "=== $label ==="
    local found=false
    for skill in "$REPO_DIR/skills/"*/; do
        skill_name=$(basename "$skill")
        targets="$(skill_targets "$skill")"
        if targets_include "$targets" "$tool"; then
            echo "$skill_name"
            found=true
        fi
    done
    if [ "$found" = false ]; then
        echo "(none)"
    fi
}

list_cursor_rules() {
    echo ""
    echo "=== Cursor rules ==="
    local found=false
    for rule in "$REPO_DIR/cursor-rules/"*.mdc; do
        [ -e "$rule" ] || continue
        echo "$(basename "$rule")"
        found=true
    done
    if [ "$found" = false ]; then
        echo "(none)"
    fi
}

if [ "$LIST_ONLY" = true ]; then
    echo "Listing installable items from $REPO_DIR"
    [ "$INSTALL_CLAUDE" = true ] && list_skills "claude" "Claude skills"
    [ "$INSTALL_CODEX" = true ] && list_skills "codex" "Codex skills"
    [ "$INSTALL_CURSOR" = true ] && list_cursor_rules
    echo ""
    exit 0
fi

build_allowed_skills() {
    local tool="$1"
    local allowed=""
    for skill in "$REPO_DIR/skills/"*/; do
        skill_name=$(basename "$skill")
        targets="$(skill_targets "$skill")"
        if targets_include "$targets" "$tool"; then
            allowed="$allowed $skill_name"
        fi
    done
    echo "$allowed" | xargs
}

is_in_list() {
    local name="$1"
    shift
    for item in "$@"; do
        if [ "$item" = "$name" ]; then
            return 0
        fi
    done
    return 1
}

prune_skill_links() {
    local tool="$1"
    local dir="$2"
    if [ ! -d "$dir" ]; then
        echo ""
        echo "=== Pruning $tool skills ==="
        echo "Directory not found: $dir"
        return
    fi
    local allowed
    allowed="$(build_allowed_skills "$tool")"

    echo ""
    echo "=== Pruning $tool skills ==="
    local removed=false
    for link in "$dir"/*; do
        [ -L "$link" ] || continue
        local name
        name="$(basename "$link")"
        local target
        target="$(readlink "$link")"
        case "$target" in
            "$REPO_DIR/skills/"*)
                if ! is_in_list "$name" $allowed; then
                    rm "$link"
                    echo "Removed $name (not targeted for $tool)"
                    removed=true
                elif [ ! -d "$target" ]; then
                    rm "$link"
                    echo "Removed $name (target missing)"
                    removed=true
                fi
                ;;
        esac
    done
    if [ "$removed" = false ]; then
        echo "No links removed."
    fi
}

prune_cursor_links() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo ""
        echo "=== Pruning Cursor rules ==="
        echo "Directory not found: $dir"
        return
    fi
    local allowed=""
    for rule in "$REPO_DIR/cursor-rules/"*.mdc; do
        [ -e "$rule" ] || continue
        allowed="$allowed $(basename "$rule")"
    done
    allowed="$(echo "$allowed" | xargs)"

    echo ""
    echo "=== Pruning Cursor rules ==="
    local removed=false
    for link in "$dir"/*; do
        [ -L "$link" ] || continue
        local name
        name="$(basename "$link")"
        local target
        target="$(readlink "$link")"
        case "$target" in
            "$REPO_DIR/cursor-rules/"*)
                if ! is_in_list "$name" $allowed; then
                    rm "$link"
                    echo "Removed $name (no longer in repo)"
                    removed=true
                elif [ ! -f "$target" ]; then
                    rm "$link"
                    echo "Removed $name (target missing)"
                    removed=true
                fi
                ;;
        esac
    done
    if [ "$removed" = false ]; then
        echo "No links removed."
    fi
}

if [ "$PRUNE" = true ]; then
    [ "$INSTALL_CLAUDE" = true ] && prune_skill_links "claude" "$CLAUDE_SKILLS_DIR"
    [ "$INSTALL_CODEX" = true ] && prune_skill_links "codex" "$CODEX_SKILLS_DIR"
    [ "$INSTALL_CURSOR" = true ] && prune_cursor_links "$CURSOR_RULES_DIR"
fi

# Install Claude skills
if [ "$INSTALL_CLAUDE" = true ]; then
    echo ""
    echo "=== Installing Claude skills ==="
    mkdir -p "$CLAUDE_SKILLS_DIR"

    for skill in "$REPO_DIR/skills/"*/; do
        skill_name=$(basename "$skill")
        targets="$(skill_targets "$skill")"
        if ! targets_include "$targets" "claude"; then
            continue
        fi
        target="$CLAUDE_SKILLS_DIR/$skill_name"

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
fi

# Install Codex skills
if [ "$INSTALL_CODEX" = true ]; then
    echo ""
    echo "=== Installing Codex skills ==="
    mkdir -p "$CODEX_SKILLS_DIR"

    for skill in "$REPO_DIR/skills/"*/; do
        skill_name=$(basename "$skill")
        targets="$(skill_targets "$skill")"
        if ! targets_include "$targets" "codex"; then
            continue
        fi
        target="$CODEX_SKILLS_DIR/$skill_name"

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
fi

# Install Cursor rules
if [ "$INSTALL_CURSOR" = true ]; then
    echo ""
    echo "=== Installing Cursor rules ==="
    mkdir -p "$CURSOR_RULES_DIR"

    for rule in "$REPO_DIR/cursor-rules/"*.mdc; do
        [ -e "$rule" ] || continue  # Skip if no .mdc files exist
        rule_name=$(basename "$rule")
        target="$CURSOR_RULES_DIR/$rule_name"

        if [ -L "$target" ]; then
            if [ "$FORCE" = true ]; then
                rm "$target"
            else
                echo "Skipping $rule_name (symlink exists, use --force to update)"
                continue
            fi
        elif [ -e "$target" ]; then
            echo "Skipping $rule_name (file exists at $target)"
            continue
        fi

        ln -s "$rule" "$target"
        echo "Linked $rule_name -> $target"
    done
fi

echo ""
echo "Done!"
[ "$INSTALL_CLAUDE" = true ] && echo "Claude skills are now available in Claude Code."
[ "$INSTALL_CODEX" = true ] && echo "Codex skills are now available in $CODEX_SKILLS_DIR."
[ "$INSTALL_CURSOR" = true ] && echo "Cursor rules are now available in ~/.cursor/rules/"
