#!/bin/bash
# Hook: Claude finished working

# Get session-specific title file using TTY from environment
TTY_ID="${CLAUDE_TTY_ID:-$(tty | tr '/' '_')}"
TITLE_FILE="$HOME/.claude/current-title-$TTY_ID"

# Get project and branch for title
project=$(basename "$PWD")
branch=$(git branch --show-current 2>/dev/null || echo "no-git")

# Update tab title to show done (only affects THIS tab)
echo "#$project #$branch ✓ done" > "$TITLE_FILE"

# Send macOS notification
if command -v osascript &>/dev/null; then
    osascript -e 'display notification "Claude finished working" with title "Claude Code" sound name "Glass"'
fi

# Ring terminal bell (works with Ghostty, iTerm2, etc.)
printf '\a'
