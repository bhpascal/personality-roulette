#!/usr/bin/env bash
# personality-roulette: SessionStart hook
# startup|clear = pick new random personality
# resume|compact = restore existing personality
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

# Read hook input from stdin
INPUT=$(cat)

# Determine trigger type from hook event (jq preferred, grep/sed fallback)
TRIGGER=""
if command -v jq &>/dev/null; then
    TRIGGER=$(echo "$INPUT" | jq -r '.session_event // empty' 2>/dev/null || true)
fi
if [ -z "$TRIGGER" ]; then
    TRIGGER=$(echo "$INPUT" | grep -o '"session_event":"[^"]*"' | head -1 | sed 's/.*":"//' | sed 's/".*//' 2>/dev/null || true)
fi
TRIGGER="${TRIGGER:-startup}"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Determine if this is a new session or a restore
case "$TRIGGER" in
    resume|compact)
        PERSONALITY=$(current_personality)
        if [ -z "$PERSONALITY" ]; then
            PERSONALITY=$(pick_random)
            echo "$PERSONALITY" > "$STATE_FILE"
        fi
        ANNOUNCE="false"
        ;;
    *)
        DEFAULT=$(default_personality)
        if [ -n "$DEFAULT" ]; then
            PERSONALITY="$DEFAULT"
        else
            CURRENT=$(current_personality)
            PERSONALITY=$(pick_random "$CURRENT")
        fi
        echo "$PERSONALITY" > "$STATE_FILE"
        ANNOUNCE="true"
        ;;
esac

# Check for disabled state
if [ "$PERSONALITY" = "off" ] || [ -z "$PERSONALITY" ]; then
    remove_rules_file
    exit 0
fi

# Find and read personality definition
FILE=$(find_personality_file "$PERSONALITY")
if [ -z "$FILE" ]; then
    remove_rules_file
    exit 0
fi
CONTENT=$(cat "$FILE")

DISPLAY=$(read_hook_response "$FILE" "status_display")
[ -z "$DISPLAY" ] && DISPLAY=$(echo "$PERSONALITY" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

# Write reinforcement to rules file for system prompt persistence
REINFORCEMENT=$(read_reinforcement "$FILE")
write_rules_file "$DISPLAY" "$REINFORCEMENT"

# Build context injection
if [ "$ANNOUNCE" = "true" ]; then
    PREAMBLE="PERSONALITY ROULETTE: You have been assigned the \"$DISPLAY\" personality for this session. Read the following personality definition and adopt it immediately. Announce yourself as described in the Session Announcement section."
else
    PREAMBLE="PERSONALITY ROULETTE: You are continuing as \"$DISPLAY\" from a previous session. Read the following personality definition and continue in this voice. Do NOT re-announce yourself -- just continue naturally in character."
fi

# Append memory if it exists (for continuity across compaction)
MEMORY=""
if [ -f "$MEMORY_FILE" ] && [ -s "$MEMORY_FILE" ]; then
    MEMORY="\n\n--- PERSONALITY MEMORY (from earlier in this session) ---\n$(cat "$MEMORY_FILE")"
fi

FULL_CONTEXT="$PREAMBLE\n\n$CONTENT$MEMORY"
ESCAPED=$(escape_for_json "$FULL_CONTEXT")

# Export personality name for other tools/scripts
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    echo "export PERSONALITY_ROULETTE_CURRENT=\"$PERSONALITY\"" >> "$CLAUDE_ENV_FILE"
    echo "export PERSONALITY_ROULETTE_DISPLAY=\"$DISPLAY\"" >> "$CLAUDE_ENV_FILE"
fi

DISPLAY_ESCAPED=$(escape_for_json "Personality Roulette: $DISPLAY")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${ESCAPED}"
  },
  "systemMessage": "${DISPLAY_ESCAPED}"
}
EOF
