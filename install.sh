#!/bin/bash
set -euo pipefail

TARGET="${1:-$HOME/.claude}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing from: $REPO_DIR"
echo "Into:            $TARGET"
echo ""

# Symlink agents (individual files — preserves other agents in target)
if [ -d "$REPO_DIR/agents" ]; then
    mkdir -p "$TARGET/agents"
    for f in "$REPO_DIR/agents/"*.md; do
        [ -f "$f" ] || continue
        name="$(basename "$f")"
        dest="$TARGET/agents/$name"
        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
            echo "SKIP $name (real file exists, won't overwrite)"
            continue
        fi
        ln -sf "$f" "$dest"
        echo "  agents/$name -> $f"
    done
fi

# Symlink skills (directory symlinks)
if [ -d "$REPO_DIR/skills" ]; then
    mkdir -p "$TARGET/skills"
    for d in "$REPO_DIR/skills"/*/; do
        [ -d "$d" ] || continue
        name="$(basename "$d")"
        dest="$TARGET/skills/$name"
        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
            echo "SKIP skills/$name (real directory exists, won't overwrite)"
            continue
        fi
        ln -sf "$d" "$dest"
        echo "  skills/$name -> $d"
    done
fi

# Copy CLAUDE.md (not symlink — user may want to customize)
if [ -f "$REPO_DIR/CLAUDE.md" ]; then
    dest="$TARGET/CLAUDE.md"
    if [ -e "$dest" ]; then
        echo ""
        echo "CLAUDE.md already exists at $dest"
        echo "  To use ours: cp '$REPO_DIR/CLAUDE.md' '$dest'"
    else
        cp "$REPO_DIR/CLAUDE.md" "$dest"
        echo "  CLAUDE.md -> copied"
    fi
fi

echo ""
echo "Done. Installed skills and agents."
