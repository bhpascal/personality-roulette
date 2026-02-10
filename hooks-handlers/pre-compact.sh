#!/usr/bin/env bash
# personality-roulette: PreCompact hook
# Saves personality narrative state before compaction wipes context
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

PERSONALITY=$(current_personality)

if [ -z "$PERSONALITY" ] || [ "$PERSONALITY" = "off" ]; then
    exit 0
fi

# Read hook input from stdin (includes transcript_path)
INPUT=$(cat)

# Try to extract transcript path for mining character details
TRANSCRIPT_PATH=""
if command -v jq &>/dev/null; then
    TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)
fi

FILE=$(find_personality_file "$PERSONALITY")
DISPLAY=$(read_hook_response "$FILE" "status_display")
[ -z "$DISPLAY" ] && DISPLAY=$(echo "$PERSONALITY" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

# For hyperintelligence, try to find the self-chosen name in the transcript
if [ "$PERSONALITY" = "hyperintelligence" ] && [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    SHIP_NAME=""
    if command -v jq &>/dev/null; then
        SHIP_NAME=$(jq -r 'select(.role=="assistant") | .content // empty' "$TRANSCRIPT_PATH" 2>/dev/null \
            | head -50 \
            | grep -oE '"[A-Z][^"]{10,}"' \
            | head -1 \
            | tr -d '"' || true)
    fi

    if [ -n "$SHIP_NAME" ]; then
        echo "This session's chosen name: $SHIP_NAME" > "$MEMORY_FILE"
    else
        echo "$DISPLAY personality active. Ship name was chosen at session start but could not be extracted for memory." > "$MEMORY_FILE"
    fi
else
    echo "$DISPLAY personality active. Continue in character." > "$MEMORY_FILE"
fi

exit 0
