#!/bin/bash
# ============================================================
# Claude Code Tab Titles - Helper Functions
# ============================================================
# Sourced by notify scripts to build titles with configuration.
# ============================================================

# Load configuration (with defaults)
load_config() {
    # Defaults
    TITLE_FORMAT='#$PROJECT #$BRANCH $STATUS'
    TICKET_SOURCE="branch"
    TICKET_PATTERN="[A-Z]+-[0-9]+"
    TICKET_ENV_VAR="CLAUDE_TICKET"
    TICKET_FILE=".ticket"
    PROJECT_NAME=""
    ICON_READY="⏳"
    ICON_WORKING="🔄"
    ICON_DONE="✓"
    ICON_WAITING="⏳"
    ICON_PERMISSION="⚠️"
    NOTIFY_IDLE="true"
    NOTIFY_PERMISSION="true"
    NOTIFY_STOP="true"
    BELL_IDLE="true"
    BELL_PERMISSION="true"
    BELL_STOP="true"

    # Load user config if exists
    if [[ -f "$HOME/.claude/tab-titles.conf" ]]; then
        source "$HOME/.claude/tab-titles.conf"
    fi
}

# Get the project name
get_project() {
    # Check for per-project override file
    if [[ -f ".claude-project" ]]; then
        cat ".claude-project"
        return
    fi

    # Use configured project name or directory name
    if [[ -n "$PROJECT_NAME" ]]; then
        echo "$PROJECT_NAME"
    else
        basename "$PWD"
    fi
}

# Get the git branch
get_branch() {
    git branch --show-current 2>/dev/null || echo "no-git"
}

# Get the ticket ID based on configuration
get_ticket() {
    local ticket=""

    case "$TICKET_SOURCE" in
        branch)
            # Extract ticket from branch name using pattern
            local branch=$(get_branch)
            ticket=$(echo "$branch" | grep -oE "$TICKET_PATTERN" | head -1)
            ;;
        env)
            # Read from environment variable
            ticket="${!TICKET_ENV_VAR}"
            ;;
        file)
            # Read from file in project root
            if [[ -f "$TICKET_FILE" ]]; then
                ticket=$(cat "$TICKET_FILE" | tr -d '\n')
            fi
            ;;
        none)
            ticket=""
            ;;
    esac

    echo "$ticket"
}

# Get the status icon
get_status_icon() {
    local status="$1"
    case "$status" in
        ready)      echo "$ICON_READY" ;;
        working)    echo "$ICON_WORKING" ;;
        done)       echo "$ICON_DONE" ;;
        waiting)    echo "$ICON_WAITING" ;;
        permission) echo "$ICON_PERMISSION" ;;
        *)          echo "" ;;
    esac
}

# Build the title string from format template
build_title() {
    local status_name="$1"  # ready, working, done, waiting, permission

    # Get all the variables
    local PROJECT=$(get_project)
    local BRANCH=$(get_branch)
    local TICKET=$(get_ticket)
    local STATUS_ICON=$(get_status_icon "$status_name")
    local STATUS="$STATUS_ICON $status_name"

    # If no ticket found, clean up the format to avoid double spaces
    local title="$TITLE_FORMAT"

    # Replace variables
    title="${title//\$PROJECT/$PROJECT}"
    title="${title//\$BRANCH/$BRANCH}"
    title="${title//\$TICKET/$TICKET}"
    title="${title//\$STATUS/$STATUS}"

    # Clean up extra spaces from empty variables
    title=$(echo "$title" | sed 's/  */ /g' | sed 's/^ //;s/ $//')

    echo "$title"
}

# Get the session-specific title file path
get_title_file() {
    local tty_id="${CLAUDE_TTY_ID:-$(tty | tr '/' '_')}"
    echo "$HOME/.claude/current-title-$tty_id"
}

# Write title to session file
write_title() {
    local status="$1"
    local title=$(build_title "$status")
    local title_file=$(get_title_file)
    echo "$title" > "$title_file"
}

# Send macOS notification
send_notification() {
    local message="$1"
    local sound="$2"

    if command -v osascript &>/dev/null; then
        osascript -e "display notification \"$message\" with title \"Claude Code\" sound name \"$sound\""
    fi
}

# Ring terminal bell
ring_bell() {
    printf '\a'
}

# Initialize - load config on source
load_config
