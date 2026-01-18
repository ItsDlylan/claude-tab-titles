#!/bin/bash
# Hook: Claude needs permission to continue

# Load helper functions and config
source "$HOME/.claude/scripts/title-helper.sh"

# Update tab title
write_title "permission"

# Send notification if enabled
if [[ "$NOTIFY_PERMISSION" == "true" ]]; then
    send_notification "Claude needs permission to continue" "Purr"
fi

# Ring bell if enabled
if [[ "$BELL_PERMISSION" == "true" ]]; then
    ring_bell
fi
