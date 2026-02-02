#!/bin/bash

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

install_cursor_rules() {
    echo ""
    echo "=== Installing Cursor rules ==="
    mkdir -p "$CURSOR_RULES_DIR"

    for rule in "$REPO_DIR/cursor-rules/"*.mdc; do
        [ -e "$rule" ] || continue
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
}
