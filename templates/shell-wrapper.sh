# ============================================================
# Claude Code Tab Titles - Shell Wrapper
# ============================================================
# This wrapper function replaces the default `claude` command to add
# automatic tab title updates showing project, branch, and status.
#
# Installed by: claude-tab-titles
# ============================================================

# Disable Claude's built-in terminal title (we handle it ourselves)
export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1

claude() {
    local project=$(basename "$PWD")
    local branch=$(git branch --show-current 2>/dev/null || echo "no-git")

    # Get unique TTY identifier for this terminal session
    # Each tab has a unique TTY (e.g., /dev/ttys001) - transform to safe filename
    local tty_id=$(tty | tr '/' '_')
    export CLAUDE_TTY_ID="$tty_id"

    # Session-specific title file (isolates parallel Claude instances)
    local title_file="$HOME/.claude/current-title-$tty_id"

    # Set initial title (waiting for first prompt)
    local title="#$project #$branch ⏳ ready"
    printf '\033]0;%s\007' "$title"
    echo "$title" > "$title_file"

    # Start title watcher for THIS session's title file
    ~/.claude/scripts/title-watcher.sh "$tty_id" &
    local watcher_pid=$!

    # Find and run the real Claude binary
    local claude_bin=""
    if [[ -x "$HOME/.local/bin/claude" ]]; then
        claude_bin="$HOME/.local/bin/claude"
    elif command -v claude &>/dev/null; then
        claude_bin=$(command -v claude)
    else
        echo "Error: Claude CLI not found. Please install it first."
        kill $watcher_pid 2>/dev/null
        rm -f "$title_file"
        return 1
    fi

    # Run Claude with all arguments passed through
    # CLAUDE_TTY_ID env var is inherited by hooks
    "$claude_bin" "$@"
    local exit_code=$?

    # Cleanup: kill watcher and remove session-specific title file
    kill $watcher_pid 2>/dev/null
    rm -f "$title_file"

    return $exit_code
}

# ============================================================
# End Claude Code Tab Titles
# ============================================================
