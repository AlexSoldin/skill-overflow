#!/bin/bash

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
