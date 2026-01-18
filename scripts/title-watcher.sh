#!/bin/bash
# Title watcher - runs in background before Claude starts
# Watches session-specific title file and updates terminal when it changes
#
# Usage: title-watcher.sh <tty_id>
# Each terminal tab has its own TTY, enabling isolated title updates

# Accept TTY ID as argument, fallback to deriving it from current tty
TTY_ID="${1:-$(tty | tr '/' '_')}"
TITLE_FILE="$HOME/.claude/current-title-$TTY_ID"

touch "$TITLE_FILE"

# Set initial title if file has content
if [[ -s "$TITLE_FILE" ]]; then
    printf '\033]0;%s\007' "$(cat "$TITLE_FILE")"
fi

# Watch for changes using fswatch (fast) or polling (fallback)
if command -v fswatch &>/dev/null; then
    fswatch -o "$TITLE_FILE" | while read; do
        if [[ -s "$TITLE_FILE" ]]; then
            printf '\033]0;%s\007' "$(cat "$TITLE_FILE")"
        fi
    done
else
    # Fallback: poll every second
    last_content=""
    while true; do
        if [[ -s "$TITLE_FILE" ]]; then
            content=$(cat "$TITLE_FILE")
            if [[ "$content" != "$last_content" ]]; then
                printf '\033]0;%s\007' "$content"
                last_content="$content"
            fi
        fi
        sleep 1
    done
fi
