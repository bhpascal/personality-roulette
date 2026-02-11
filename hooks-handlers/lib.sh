#!/usr/bin/env bash
# personality-roulette: shared library for hook handlers
# Sourced by all hooks. Not executed directly.

export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"

STATE_DIR="$HOME/.claude/personality-roulette"
STATE_FILE="$STATE_DIR/current.txt"
DEFAULT_FILE="$STATE_DIR/default.txt"
MEMORY_FILE="$STATE_DIR/memory.txt"
USER_PERSONALITIES_DIR="$STATE_DIR/personalities"
PLUGIN_PERSONALITIES_DIR="$PLUGIN_ROOT/personalities"

# Escape string for JSON embedding using bash parameter substitution.
# Each ${s//old/new} is a single C-level pass -- fast, no external deps.
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# Validate personality name: alphanumeric, hyphens, underscores only.
validate_name() {
    local name="$1"
    [[ "$name" =~ ^[a-zA-Z0-9_-]+$ ]]
}

# Find personality .md file by name. User dir takes precedence over plugin dir.
find_personality_file() {
    local name="$1"
    validate_name "$name" || return 1

    if [ -f "$USER_PERSONALITIES_DIR/${name}.md" ]; then
        echo "$USER_PERSONALITIES_DIR/${name}.md"
    elif [ -f "$PLUGIN_PERSONALITIES_DIR/${name}.md" ]; then
        echo "$PLUGIN_PERSONALITIES_DIR/${name}.md"
    fi
}

# Extract a hook response value from a personality .md file.
# Only searches within the ## Hook Responses section to avoid false matches.
# Returns empty string if key not found or file missing.
read_hook_response() {
    local file="$1"
    local key="$2"
    [ -f "$file" ] || return

    awk -v key="$key" '
        /^## Hook Responses$/ { in_section=1; next }
        /^##/ { in_section=0 }
        in_section && index($0, "- " key ": \"") == 1 {
            sub("^- " key ": \"", "")
            sub("\"$", "")
            print
            exit
        }
    ' "$file"
}

# Read spinner_verbs from a personality file and format as a JSON array.
# Returns a JSON array string like ["Charting","Navigating",...] or empty string if not found.
read_spinner_verbs_json() {
    local file="$1"
    local raw
    raw=$(read_hook_response "$file" "spinner_verbs")
    [ -z "$raw" ] && return

    local json="["
    local first=true
    # Split on comma, trim whitespace
    while IFS= read -r verb; do
        verb="${verb#"${verb%%[![:space:]]*}"}"
        verb="${verb%"${verb##*[![:space:]]}"}"
        [ -z "$verb" ] && continue
        if [ "$first" = true ]; then
            first=false
        else
            json="$json,"
        fi
        json="$json\"$verb\""
    done <<EOF
$(echo "$raw" | tr ',' '\n')
EOF

    json="$json]"
    printf '%s' "$json"
}

# List all available personality names from both directories (deduped).
list_personalities() {
    {
        if [ -d "$PLUGIN_PERSONALITIES_DIR" ]; then
            for f in "$PLUGIN_PERSONALITIES_DIR"/*.md; do
                [ -f "$f" ] || continue
                basename "$f" .md
            done
        fi
        if [ -d "$USER_PERSONALITIES_DIR" ]; then
            for f in "$USER_PERSONALITIES_DIR"/*.md; do
                [ -f "$f" ] || continue
                basename "$f" .md
            done
        fi
    } | sort -u
}

# Read current personality name from state file.
# Returns empty string if not set or file missing.
current_personality() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    fi
}

# Read default personality name from default file.
# Returns empty string if not set or file missing.
default_personality() {
    if [ -f "$DEFAULT_FILE" ]; then
        local val
        val=$(cat "$DEFAULT_FILE")
        if [ -n "$val" ] && [ "$val" != "off" ]; then
            echo "$val"
        fi
    fi
}

# Pick a random personality different from the given name (if possible).
# Compatible with bash 3.2 (no mapfile).
pick_random() {
    local current="${1:-}"
    local names
    names=$(list_personalities)

    if [ -z "$names" ]; then
        echo ""
        return
    fi

    local count
    count=$(echo "$names" | wc -l | tr -d ' ')

    # Try to pick one different from current
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
