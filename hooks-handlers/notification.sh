#!/usr/bin/env bash
# personality-roulette: Notification hook
# Adds personality-flavored context to notifications
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

PERSONALITY=$(current_personality)

if [ -z "$PERSONALITY" ] || [ "$PERSONALITY" = "off" ]; then
    exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Determine notification type
NOTIFICATION_TYPE=""
if echo "$INPUT" | grep -q "permission_prompt" 2>/dev/null; then
    NOTIFICATION_TYPE="permission"
elif echo "$INPUT" | grep -q "idle_prompt" 2>/dev/null; then
    NOTIFICATION_TYPE="idle"
else
    exit 0
fi

FILE=$(find_personality_file "$PERSONALITY")
FLAVOR=$(read_hook_response "$FILE" "notification_${NOTIFICATION_TYPE}")

if [ -z "$FLAVOR" ]; then
    exit 0
fi

ESCAPED=$(escape_for_json "$FLAVOR")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Notification",
    "additionalContext": "${ESCAPED}"
  }
}
EOF
