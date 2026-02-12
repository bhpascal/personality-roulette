#!/usr/bin/env bash
# personality-roulette: SessionEnd hook
# Cleans up personality state when a session ends
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/lib.sh"

# Clear memory file so it doesn't leak into a future session
if [ -f "$MEMORY_FILE" ]; then
    rm -f "$MEMORY_FILE"
fi

exit 0
