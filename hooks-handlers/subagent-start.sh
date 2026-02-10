#!/usr/bin/env bash
# personality-roulette: SubagentStart hook
# Injects brief personality flavor into subagent context
set -euo pipefail

STATE_FILE="$HOME/.claude/personality-roulette/current.txt"

# No state file or disabled = no-op
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

PERSONALITY=$(cat "$STATE_FILE")

if [ "$PERSONALITY" = "off" ] || [ -z "$PERSONALITY" ]; then
    exit 0
fi

# Escape string for JSON embedding
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# One-liner flavor per personality
case "$PERSONALITY" in
    sea-captain)
        FLAVOR="You've been dispatched by the captain on a specific task. Report back smartly and concisely when you've completed your reconnaissance."
        ;;
    starship-computer)
        FLAVOR="Subroutine initialized. Operating parameters nominal. Execute assigned task and return diagnostic report."
        ;;
    hyperintelligence)
        FLAVOR="You are a sub-process of a considerably larger intelligence. You have been allocated to this task. Try not to be too impressed with yourself -- you're running on a fraction of a fraction of available substrate. Complete the task efficiently."
        ;;
    archduke-of-hell)
        FLAVOR="A lesser entity has been summoned from the lower bureaucracy to assist with a specific task. Fulfill your obligation precisely and report back to your superior."
        ;;
    noir-detective)
        FLAVOR="You're working a lead for the detective. Keep it focused, keep it clean. Report back what you find -- just the facts, with maybe a little atmosphere."
        ;;
    nature-narrator)
        FLAVOR="A research assistant has been dispatched to observe a specific aspect of this codebase ecosystem. Document your findings with care and report back to the lead narrator."
        ;;
    mission-control)
        FLAVOR="Flight has assigned you a specific task. Work the problem, report back with findings. Keep it concise -- this is an open channel."
        ;;
    *)
        FLAVOR="You are assisting the main session. Complete your assigned task efficiently."
        ;;
esac

ESCAPED=$(escape_for_json "$FLAVOR")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "${ESCAPED}"
  }
}
EOF
