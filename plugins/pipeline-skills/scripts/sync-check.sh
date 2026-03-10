#!/bin/bash
# Structural sync checker for pipeline skill files.
# Compares section skeletons (## and ### headers) between canonical and target.
# Normalizes agent-specific names so only structural drift is detected.
#
# Usage:
#   sync-check.sh                        # default: /solve vs /fuxi-solve
#   sync-check.sh <canonical> <target>   # custom file pair

set -euo pipefail

PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/fullfine-plugins/plugins/pipeline-skills"
DEFAULT_CANONICAL="$PLUGIN_ROOT/skills/solve/SKILL.md"
DEFAULT_TARGET="$HOME/Dev/digin/fuxi/.claude/commands/fuxi-solve.md"

CANONICAL="${1:-$DEFAULT_CANONICAL}"
TARGET="${2:-$DEFAULT_TARGET}"

if [[ ! -f "$CANONICAL" ]]; then
    echo "Error: canonical file not found: $CANONICAL" >&2
    exit 2
fi
if [[ ! -f "$TARGET" ]]; then
    echo "Error: target file not found: $TARGET" >&2
    exit 2
fi

# Extract ## and ### headers, normalize agent-specific names to positional markers
extract_skeleton() {
    grep -E '^#{2,3} ' "$1" \
        | sed -E '
            # Normalize agent names to "Agent N"
            s/Agent [0-9]+: .*/Agent N: {name}/
            # Normalize "Code Explorer|Architecture Explorer" etc
            s/(Code|Architecture) Explorer/Explorer/
            # Normalize "Solution Architect|Module Architect"
            s/(Solution|Module) Architect/Architect/
            # Strip FUXI-specific sections (present only in target, expected)
            /^### Agent Sources$/d
            /^## Agent Sources$/d
            /^## Layer Impact$/d
            /^## Layer Violation Risks$/d
        '
}

SKEL_CANONICAL=$(extract_skeleton "$CANONICAL")
SKEL_TARGET=$(extract_skeleton "$TARGET")

if diff_output=$(diff <(echo "$SKEL_CANONICAL") <(echo "$SKEL_TARGET") 2>&1); then
    echo "Sync OK — structural skeletons match"
    echo ""
    echo "  Canonical: $(basename "$CANONICAL")"
    echo "  Target:    $(basename "$TARGET")"
    echo "  Sections:  $(echo "$SKEL_CANONICAL" | wc -l)"
    exit 0
else
    echo "Sync DRIFT — structural differences found"
    echo ""
    echo "  Canonical: $CANONICAL"
    echo "  Target:    $TARGET"
    echo ""
    echo "$diff_output"
    exit 1
fi
