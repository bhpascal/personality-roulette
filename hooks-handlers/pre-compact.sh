#!/usr/bin/env bash
# personality-roulette: PreCompact hook
# Saves personality narrative state before compaction wipes context
set -euo pipefail

STATE_DIR="$HOME/.claude/personality-roulette"
STATE_FILE="$STATE_DIR/current.txt"
MEMORY_FILE="$STATE_DIR/memory.txt"

# No state file or disabled = no-op
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

PERSONALITY=$(cat "$STATE_FILE")

if [ "$PERSONALITY" = "off" ] || [ -z "$PERSONALITY" ]; then
    exit 0
fi

# Read hook input from stdin (includes transcript_path)
INPUT=$(cat)

# Try to extract transcript path for mining character details
TRANSCRIPT_PATH=""
if command -v jq &>/dev/null; then
    TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)
fi

# For hyperintelligence personality, try to find the ship name Claude chose
if [ "$PERSONALITY" = "hyperintelligence" ] && [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # Look for the self-chosen name in the transcript
    # The hyperintelligence announces a ship-style name in quotes at session start
    SHIP_NAME=""
    if command -v jq &>/dev/null; then
        # Search for quoted ship-style names in assistant messages
        SHIP_NAME=$(jq -r 'select(.role=="assistant") | .content // empty' "$TRANSCRIPT_PATH" 2>/dev/null \
            | head -50 \
            | grep -oE '"[A-Z][^"]{10,}"' \
            | head -1 \
            | tr -d '"' || true)
    fi

    if [ -n "$SHIP_NAME" ]; then
        echo "This session's chosen name: $SHIP_NAME" > "$MEMORY_FILE"
    else
        # If we can't extract the name, at least note the personality is active
        echo "Hyperintelligence personality active. Ship name was chosen at session start but could not be extracted for memory." > "$MEMORY_FILE"
    fi

elif [ "$PERSONALITY" = "noir-detective" ] && [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # For noir detective, capture any case-specific details
    echo "Noir detective personality active. Continue the investigation in character." > "$MEMORY_FILE"

elif [ "$PERSONALITY" = "nature-narrator" ] && [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    echo "Nature documentary narrator personality active. Continue observing this codebase habitat." > "$MEMORY_FILE"

else
    # Generic memory for other personalities
    DISPLAY=$(echo "$PERSONALITY" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
    echo "$DISPLAY personality active. Continue in character." > "$MEMORY_FILE"
fi

# No JSON output needed -- PreCompact hook just needs to run
exit 0
