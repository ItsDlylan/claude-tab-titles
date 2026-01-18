#!/bin/bash
# Hook: Claude finished working

# Load helper functions and config
source "$HOME/.claude/scripts/title-helper.sh"

# Update tab title
write_title "done"

# Send notification if enabled
if [[ "$NOTIFY_STOP" == "true" ]]; then
    send_notification "Claude finished working" "Glass"
fi

# Ring bell if enabled
if [[ "$BELL_STOP" == "true" ]]; then
    ring_bell
fi
