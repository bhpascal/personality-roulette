#!/usr/bin/env bash
# personality-roulette: Status line display
# Reads current personality and outputs a display string
# Users can configure this in their Claude Code status line settings
set -euo pipefail

STATE_FILE="$HOME/.claude/personality-roulette/current.txt"

if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

PERSONALITY=$(cat "$STATE_FILE")

if [ "$PERSONALITY" = "off" ] || [ -z "$PERSONALITY" ]; then
    exit 0
fi

# Display name mapping
case "$PERSONALITY" in
    sea-captain)         echo "Sea Captain" ;;
    starship-computer)   echo "Starship Computer" ;;
    hyperintelligence)   echo "Hyperintelligence" ;;
    archduke-of-hell)    echo "Archduke of Hell" ;;
    noir-detective)      echo "Noir Detective" ;;
    nature-narrator)     echo "Nature Narrator" ;;
    mission-control)     echo "Mission Control" ;;
    *)                   echo "$PERSONALITY" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' ;;
esac
