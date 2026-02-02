#!/bin/bash

normalize_targets() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[]' | tr ',"' ' ' | xargs
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
