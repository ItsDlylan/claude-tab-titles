#!/bin/bash
# ============================================================
# Claude Code Tab Titles - Configuration
# ============================================================
# Customize your tab title format and ticket integration.
# This file is sourced by the notify scripts.
#
# Location: ~/.claude/tab-titles.conf
# ============================================================

# ------------------------------
# TITLE FORMAT
# ------------------------------
# Customize how your tab title appears using these variables:
#   $PROJECT  - Current directory name (or custom project name)
#   $BRANCH   - Current git branch
#   $TICKET   - Ticket ID from your project management tool
#   $STATUS   - Current status (ready, working, done, waiting, permission)
#
# Default: "#$PROJECT #$BRANCH $STATUS"
# Examples:
#   "#$PROJECT #$BRANCH $STATUS"           → #MyApp #main 🔄 working
#   "$TICKET #$BRANCH $STATUS"             → ENG-123 #main 🔄 working
#   "#$PROJECT $TICKET $STATUS"            → #MyApp ENG-123 🔄 working
#   "$TICKET $STATUS"                      → ENG-123 🔄 working
#   "#$PROJECT #$BRANCH $TICKET $STATUS"   → #MyApp #main ENG-123 🔄 working

TITLE_FORMAT="#\$PROJECT #\$BRANCH \$STATUS"

# ------------------------------
# TICKET DETECTION
# ------------------------------
# How to detect your ticket ID. Options:
#   "branch"   - Extract from branch name using TICKET_PATTERN regex
#   "env"      - Read from environment variable (TICKET_ENV_VAR)
#   "file"     - Read from a file in project root (TICKET_FILE)
#   "none"     - Disable ticket detection
#
# Default: "branch"

TICKET_SOURCE="branch"

# ------------------------------
# BRANCH PARSING (when TICKET_SOURCE="branch")
# ------------------------------
# Regex pattern to extract ticket ID from branch name.
# Common patterns for different tools:
#
# Linear:    "[A-Z]+-[0-9]+"              → ENG-123, FE-456
# Jira:      "[A-Z]+-[0-9]+"              → PROJ-123, FEAT-456
# Trello:    "[0-9]+-"                    → 123- (card number prefix)
# Asana:     "[0-9]{10,}"                 → 1234567890123 (task ID)
# GitHub:    "#[0-9]+"                    → #123 (issue number)
# Shortcut:  "sc-[0-9]+"                  → sc-12345
#
# Examples of branch names and what they'd match:
#   feature/ENG-123-add-login    → ENG-123
#   bugfix/PROJ-456-fix-crash    → PROJ-456
#   123-update-readme            → 123
#
# Default: "[A-Z]+-[0-9]+" (matches Linear/Jira style)

TICKET_PATTERN="[A-Z]+-[0-9]+"

# ------------------------------
# ENVIRONMENT VARIABLE (when TICKET_SOURCE="env")
# ------------------------------
# Name of environment variable containing the ticket ID.
# You can set this in your shell or in a .envrc file (with direnv).
#
# Default: "CLAUDE_TICKET"

TICKET_ENV_VAR="CLAUDE_TICKET"

# ------------------------------
# FILE-BASED TICKET (when TICKET_SOURCE="file")
# ------------------------------
# Path to file containing ticket ID (relative to project root).
# The file should contain just the ticket ID, e.g., "ENG-123"
#
# Common options:
#   ".ticket"         - Simple dedicated file
#   ".claude-ticket"  - Claude-specific file
#   ".task"           - Generic task file
#
# Default: ".ticket"

TICKET_FILE=".ticket"

# ------------------------------
# PROJECT NAME OVERRIDE
# ------------------------------
# By default, the project name is the current directory name.
# Set this to use a custom project name instead.
# Leave empty to use the directory name.
#
# You can also create a .claude-project file in any directory
# containing the project name to override per-project.

PROJECT_NAME=""

# ------------------------------
# STATUS ICONS
# ------------------------------
# Customize the emoji/icons for each status.
# Set to empty string to show just the text.

ICON_READY="⏳"
ICON_WORKING="🔄"
ICON_DONE="✓"
ICON_WAITING="⏳"
ICON_PERMISSION="⚠️"

# ------------------------------
# NOTIFICATIONS
# ------------------------------
# Enable/disable macOS notifications for each event.
# Set to "true" or "false"

NOTIFY_IDLE="true"
NOTIFY_PERMISSION="true"
NOTIFY_STOP="true"

# ------------------------------
# TERMINAL BELL
# ------------------------------
# Ring the terminal bell on events (for Ghostty attention indicator, etc.)
# Set to "true" or "false"

BELL_IDLE="true"
BELL_PERMISSION="true"
BELL_STOP="true"
