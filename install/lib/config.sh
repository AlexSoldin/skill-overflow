#!/bin/bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
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
