#!/bin/bash

install_skill_links() {
    local tool="$1"
    local dest_dir="$2"
    local label="$3"

    echo ""
    echo "=== Installing $label ==="
    mkdir -p "$dest_dir"

    for skill in "$REPO_DIR/skills/"*/; do
        skill_name=$(basename "$skill")
        targets="$(skill_targets "$skill")"
        if ! targets_include "$targets" "$tool"; then
            continue
        fi
        target="$dest_dir/$skill_name"

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
}
