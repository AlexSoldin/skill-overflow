#!/bin/bash

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
