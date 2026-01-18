#!/bin/bash
# Hook: User submitted a prompt, Claude is now working

# Get session-specific title file using TTY from environment
TTY_ID="${CLAUDE_TTY_ID:-$(tty | tr '/' '_')}"
TITLE_FILE="$HOME/.claude/current-title-$TTY_ID"

# Get project and branch for title
project=$(basename "$PWD")
branch=$(git branch --show-current 2>/dev/null || echo "no-git")

# Update tab title to show working (only affects THIS tab)
echo "#$project #$branch 🔄 working" > "$TITLE_FILE"

# No notification needed - just update the title
