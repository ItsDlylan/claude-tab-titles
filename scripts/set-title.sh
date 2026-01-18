#!/bin/bash
# Manually set the terminal title (for use with /name-tab skill or custom scripts)
# Writes to session-specific file that title-watcher.sh is monitoring
#
# Usage: set-title.sh "My Custom Title"

TTY_ID="${CLAUDE_TTY_ID:-$(tty | tr '/' '_')}"
TITLE_FILE="$HOME/.claude/current-title-$TTY_ID"

echo "$1" > "$TITLE_FILE"
