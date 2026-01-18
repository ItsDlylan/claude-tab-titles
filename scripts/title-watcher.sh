#!/bin/bash
# Title watcher - runs in background before Claude starts
# Watches session-specific title file and continuously re-applies the title
# to prevent other processes from overriding it
#
# Usage: title-watcher.sh <tty_id>
# Each terminal tab has its own TTY, enabling isolated title updates

# Accept TTY ID as argument, fallback to deriving it from current tty
TTY_ID="${1:-$(tty | tr '/' '_')}"
TITLE_FILE="$HOME/.claude/current-title-$TTY_ID"

# How often to re-apply the title (in seconds) to override other processes
REFRESH_INTERVAL=3

touch "$TITLE_FILE"

# Function to set the terminal title
set_title() {
    if [[ -s "$TITLE_FILE" ]]; then
        printf '\033]0;%s\007' "$(cat "$TITLE_FILE")"
    fi
}

# Set initial title
set_title

# Continuously re-apply the title to prevent other processes from overriding it
# This runs in the background while also watching for file changes
while true; do
    set_title
    sleep "$REFRESH_INTERVAL"
done &
REFRESH_PID=$!

# Clean up the refresh loop when the watcher exits
trap "kill $REFRESH_PID 2>/dev/null" EXIT

# Watch for changes using fswatch (fast) or polling (fallback)
# This ensures immediate updates when the user changes the title
if command -v fswatch &>/dev/null; then
    fswatch -o "$TITLE_FILE" | while read; do
        set_title
    done
else
    # Fallback: poll every second for file changes
    last_mod=""
    while true; do
        current_mod=$(stat -f %m "$TITLE_FILE" 2>/dev/null || stat -c %Y "$TITLE_FILE" 2>/dev/null)
        if [[ "$current_mod" != "$last_mod" ]]; then
            set_title
            last_mod="$current_mod"
        fi
        sleep 1
    done
fi
