#!/usr/bin/env bash
# personality-roulette: SubagentStart hook
# Injects brief personality flavor into subagent context
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

PERSONALITY=$(current_personality)

if [ -z "$PERSONALITY" ] || [ "$PERSONALITY" = "off" ]; then
    exit 0
fi

FILE=$(find_personality_file "$PERSONALITY")
FLAVOR=$(read_hook_response "$FILE" "subagent")
[ -z "$FLAVOR" ] && FLAVOR="You are assisting the main session. Complete your assigned task efficiently."

ESCAPED=$(escape_for_json "$FLAVOR")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "${ESCAPED}"
  }
}
EOF
