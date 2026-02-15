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

# Determine notification type (jq preferred, grep fallback)
NOTIFICATION_TYPE=""
if command -v jq &>/dev/null; then
    RAW_TYPE=$(echo "$INPUT" | jq -r '.type // .notification_type // empty' 2>/dev/null || true)
    case "$RAW_TYPE" in
        permission_prompt)  NOTIFICATION_TYPE="permission" ;;
        idle_prompt)        NOTIFICATION_TYPE="idle" ;;
        auth_success)       NOTIFICATION_TYPE="auth" ;;
        elicitation_dialog) NOTIFICATION_TYPE="elicitation" ;;
    esac
fi
if [ -z "$NOTIFICATION_TYPE" ]; then
    if echo "$INPUT" | grep -q "permission_prompt" 2>/dev/null; then
        NOTIFICATION_TYPE="permission"
    elif echo "$INPUT" | grep -q "idle_prompt" 2>/dev/null; then
        NOTIFICATION_TYPE="idle"
    elif echo "$INPUT" | grep -q "auth_success" 2>/dev/null; then
        NOTIFICATION_TYPE="auth"
    elif echo "$INPUT" | grep -q "elicitation_dialog" 2>/dev/null; then
        NOTIFICATION_TYPE="elicitation"
    fi
fi
if [ -z "$NOTIFICATION_TYPE" ]; then
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
