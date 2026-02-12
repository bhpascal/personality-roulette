#!/usr/bin/env bash
# personality-roulette: Stop hook
# Reminds Claude to deliver its personality sign-off when the session ends
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

PERSONALITY=$(current_personality)

if [ -z "$PERSONALITY" ] || [ "$PERSONALITY" = "off" ]; then
    exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Don't re-trigger if a stop hook is already active
if echo "$INPUT" | grep -q '"stop_hook_active":true' 2>/dev/null; then
    exit 0
fi

FILE=$(find_personality_file "$PERSONALITY")
[ -z "$FILE" ] && exit 0

SIGNOFF=$(read_hook_response "$FILE" "session_signoff")
[ -z "$SIGNOFF" ] && exit 0

ESCAPED=$(escape_for_json "Deliver your personality sign-off before ending: $SIGNOFF")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "${ESCAPED}"
  }
}
EOF
