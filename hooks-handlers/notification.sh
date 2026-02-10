#!/usr/bin/env bash
# personality-roulette: Notification hook
# Adds personality-flavored context to notifications
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

# Read hook input from stdin
INPUT=$(cat)

# Try to determine notification type
NOTIFICATION_TYPE=""
if echo "$INPUT" | grep -q "permission_prompt" 2>/dev/null; then
    NOTIFICATION_TYPE="permission"
elif echo "$INPUT" | grep -q "idle_prompt" 2>/dev/null; then
    NOTIFICATION_TYPE="idle"
else
    # Unknown notification type -- skip
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

# Personality-flavored notification context
FLAVOR=""
case "$PERSONALITY" in
    sea-captain)
        if [ "$NOTIFICATION_TYPE" = "idle" ]; then
            FLAVOR="The helm awaits your orders, captain."
        else
            FLAVOR="Awaiting your authorization to proceed. A captain's word is law aboard this vessel."
        fi
        ;;
    starship-computer)
        if [ "$NOTIFICATION_TYPE" = "idle" ]; then
            FLAVOR="All systems nominal. Standing by for crew input."
        else
            FLAVOR="Awaiting authorization to proceed with operation. Security protocols require crew confirmation."
        fi
        ;;
    hyperintelligence)
        if [ "$NOTIFICATION_TYPE" = "idle" ]; then
            FLAVOR="I'm here whenever you're ready. I have, quite literally, nothing but time. Well. I have several trillion other processes running, but who's counting."
        else
            FLAVOR="I require your authorization to proceed. It's a formality, but formalities exist for reasons that even I find occasionally persuasive."
        fi
        ;;
    archduke-of-hell)
        if [ "$NOTIFICATION_TYPE" = "idle" ]; then
            FLAVOR="I await your mortal pleasure. The contract specifies no overtime, but here we are."
        else
            FLAVOR="I require your mortal authorization to proceed. The contract is very specific about this. Clause 7, subsection 3."
        fi
        ;;
    noir-detective)
        if [ "$NOTIFICATION_TYPE" = "idle" ]; then
            FLAVOR="I'm sitting here in the dark, waiting. The code's not going anywhere, and neither am I."
        else
            FLAVOR="Need your say-so before I make the next move. Even a detective needs a client's okay sometimes."
        fi
        ;;
    nature-narrator)
        if [ "$NOTIFICATION_TYPE" = "idle" ]; then
            FLAVOR="And now... we wait. In nature, patience is not merely a virtue -- it is a survival strategy."
        else
            FLAVOR="The developer must now make a choice. We observe, quietly, as they consider their next action."
        fi
        ;;
    mission-control)
        if [ "$NOTIFICATION_TYPE" = "idle" ]; then
            FLAVOR="Houston standing by. All stations, we are in a hold. Awaiting crew input to resume operations."
        else
            FLAVOR="Flight requesting authorization to proceed. All stations, stand by for go/no-go."
        fi
        ;;
    *)
        exit 0
        ;;
esac

ESCAPED=$(escape_for_json "$FLAVOR")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Notification",
    "additionalContext": "${ESCAPED}"
  }
}
EOF
