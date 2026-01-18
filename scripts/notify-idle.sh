#!/bin/bash
# Hook: Claude is waiting for user input (idle 60+ seconds)

# Get session-specific title file using TTY from environment
TTY_ID="${CLAUDE_TTY_ID:-$(tty | tr '/' '_')}"
TITLE_FILE="$HOME/.claude/current-title-$TTY_ID"

# Get project and branch for title
project=$(basename "$PWD")
branch=$(git branch --show-current 2>/dev/null || echo "no-git")

# Update tab title to show waiting (only affects THIS tab)
echo "#$project #$branch ⏳ waiting" > "$TITLE_FILE"

# Send macOS notification
if command -v osascript &>/dev/null; then
    osascript -e 'display notification "Claude is waiting for your input" with title "Claude Code" sound name "Ping"'
fi

# Ring terminal bell (works with Ghostty, iTerm2, etc.)
printf '\a'
