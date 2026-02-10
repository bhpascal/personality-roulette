#!/usr/bin/env bash
# personality-roulette: Status line display
# Reads current personality and outputs a display string
set -euo pipefail

# Source lib relative to this script (scripts/ is sibling to hooks-handlers/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "$SCRIPT_DIR/../hooks-handlers/lib.sh"

PERSONALITY=$(current_personality)

if [ -z "$PERSONALITY" ] || [ "$PERSONALITY" = "off" ]; then
    exit 0
fi

FILE=$(find_personality_file "$PERSONALITY")
DISPLAY=$(read_hook_response "$FILE" "status_display")

if [ -n "$DISPLAY" ]; then
    echo "$DISPLAY"
else
    # Fallback: title-case the filename
    echo "$PERSONALITY" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1'
fi
