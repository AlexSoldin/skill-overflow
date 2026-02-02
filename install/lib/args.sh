#!/bin/bash

parse_args() {
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
}

prompt_for_targets() {
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
}
