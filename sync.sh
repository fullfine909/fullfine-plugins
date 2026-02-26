#!/bin/bash
set -euo pipefail

SOURCE="${1:-$HOME/.dots/claude}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$SOURCE" ]; then
    echo "Source not found: $SOURCE"
    echo "Usage: ./sync.sh [source_path]"
    echo "Default: ~/.dots/claude"
    exit 1
fi

echo "Syncing from: $SOURCE"
echo "Into:         $REPO_DIR"
echo ""

# Sync agents
if [ -d "$SOURCE/agents" ]; then
    mkdir -p "$REPO_DIR/agents"
    rsync -av --delete "$SOURCE/agents/" "$REPO_DIR/agents/"
fi

# Sync skills
if [ -d "$SOURCE/skills" ]; then
    mkdir -p "$REPO_DIR/skills"
    rsync -av --delete "$SOURCE/skills/" "$REPO_DIR/skills/"
fi

# Sync CLAUDE.md (global preferences)
if [ -f "$SOURCE/CLAUDE.md" ]; then
    cp -v "$SOURCE/CLAUDE.md" "$REPO_DIR/CLAUDE.md"
fi

echo ""
echo "Done. Review changes with: git -C '$REPO_DIR' diff"
