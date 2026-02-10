#!/usr/bin/env bash
# personality-roulette: SessionStart hook
# startup|clear = pick new random personality
# resume|compact = restore existing personality
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
STATE_DIR="$HOME/.claude/personality-roulette"
STATE_FILE="$STATE_DIR/current.txt"
MEMORY_FILE="$STATE_DIR/memory.txt"
PERSONALITIES_DIR="$PLUGIN_ROOT/personalities"

# Read hook input from stdin
INPUT=$(cat)

# Determine trigger type from hook event
TRIGGER=$(echo "$INPUT" | grep -o '"session_event":"[^"]*"' | head -1 | sed 's/.*":"//' | sed 's/".*//' 2>/dev/null || echo "startup")

# Escape string for JSON embedding using bash parameter substitution
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# Pick a random personality different from current (if possible)
# Compatible with bash 3.2 (macOS default)
pick_random() {
    local current="${1:-}"

    # Collect personality names into a simple list
    local names=""
    local count=0
    for f in "$PERSONALITIES_DIR"/*.md; do
        [ -f "$f" ] || continue
        local name
        name=$(basename "$f" .md)
        names="${names}${name}"$'\n'
        count=$(( count + 1 ))
    done

    if [ "$count" -eq 0 ]; then
        echo ""
        return
    fi

    # Pick random line from the list, avoiding current if possible
    local attempts=0
    while [ $attempts -lt 10 ]; do
        local idx=$(( RANDOM % count + 1 ))
        local pick
        pick=$(echo "$names" | sed -n "${idx}p")
        if [ "$pick" != "$current" ] || [ "$count" -eq 1 ]; then
            echo "$pick"
            return
        fi
        attempts=$(( attempts + 1 ))
    done

    # Fallback
    local idx=$(( RANDOM % count + 1 ))
    echo "$names" | sed -n "${idx}p"
}

# Read personality file content
read_personality() {
    local name="$1"
    local file="$PERSONALITIES_DIR/$name.md"
    if [ -f "$file" ]; then
        cat "$file"
    else
        echo ""
    fi
}

# Pretty display name from filename
display_name() {
    local name="$1"
    echo "$name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1'
}

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Determine if this is a new session or a restore
case "$TRIGGER" in
    resume|compact)
        # Restore existing personality
        if [ -f "$STATE_FILE" ]; then
            PERSONALITY=$(cat "$STATE_FILE")
        else
            # State file missing on restore -- pick a new one
            PERSONALITY=$(pick_random)
            echo "$PERSONALITY" > "$STATE_FILE"
        fi
        ANNOUNCE="false"
        ;;
    *)
        # New session: pick random personality
        CURRENT=""
        [ -f "$STATE_FILE" ] && CURRENT=$(cat "$STATE_FILE")
        PERSONALITY=$(pick_random "$CURRENT")
        echo "$PERSONALITY" > "$STATE_FILE"
        ANNOUNCE="true"
        ;;
esac

# Check for disabled state
if [ "$PERSONALITY" = "off" ]; then
    exit 0
fi

# Read personality definition
CONTENT=$(read_personality "$PERSONALITY")
if [ -z "$CONTENT" ]; then
    exit 0
fi

DISPLAY=$(display_name "$PERSONALITY")

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

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${ESCAPED}"
  }
}
EOF
