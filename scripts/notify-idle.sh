#!/bin/bash
# Hook: Claude is waiting for user input (idle 60+ seconds)

# Load helper functions and config
source "$HOME/.claude/scripts/title-helper.sh"

# Update tab title
write_title "waiting"

# Send notification if enabled
if [[ "$NOTIFY_IDLE" == "true" ]]; then
    send_notification "Claude is waiting for your input" "Ping"
fi

# Ring bell if enabled
if [[ "$BELL_IDLE" == "true" ]]; then
    ring_bell
fi
