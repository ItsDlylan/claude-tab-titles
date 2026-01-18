#!/bin/bash
# ============================================================
# Claude Code Tab Titles - Installer
# ============================================================
# Installs automatic tab title updates for Claude Code CLI
# showing project name, git branch, and current status.
#
# Features:
# - Per-session isolation (multiple Claude tabs work independently)
# - Status indicators: ready, working, done, waiting, permission
# - macOS notifications when Claude needs attention
# - Works with any terminal (Ghostty, iTerm2, Terminal.app, etc.)
# ============================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Claude Code Tab Titles - Installer                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Claude CLI is installed
if ! command -v claude &>/dev/null && [[ ! -x "$HOME/.local/bin/claude" ]]; then
    echo -e "${RED}Error: Claude CLI not found.${NC}"
    echo "Please install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi
echo -e "${GREEN}✓${NC} Claude CLI found"

# Detect shell
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
    zsh)
        SHELL_RC="$HOME/.zshrc"
        ;;
    bash)
        SHELL_RC="$HOME/.bashrc"
        ;;
    *)
        echo -e "${YELLOW}Warning: Unsupported shell '$SHELL_NAME'. Defaulting to .zshrc${NC}"
        SHELL_RC="$HOME/.zshrc"
        ;;
esac
echo -e "${GREEN}✓${NC} Detected shell: $SHELL_NAME (config: $SHELL_RC)"

# Create scripts directory
echo -e "\n${BLUE}Installing scripts...${NC}"
mkdir -p "$HOME/.claude/scripts"

# Copy scripts
for script in "$SCRIPT_DIR/scripts/"*.sh; do
    script_name=$(basename "$script")
    cp "$script" "$HOME/.claude/scripts/$script_name"
    chmod +x "$HOME/.claude/scripts/$script_name"
    echo -e "  ${GREEN}✓${NC} Installed $script_name"
done

# Check if wrapper is already installed
MARKER_START="# Claude Code Tab Titles - Shell Wrapper"
MARKER_END="# End Claude Code Tab Titles"

if grep -q "$MARKER_START" "$SHELL_RC" 2>/dev/null; then
    echo -e "\n${YELLOW}Shell wrapper already installed in $SHELL_RC${NC}"
    echo -e "  To reinstall, run: ${BLUE}./uninstall.sh${NC} first"
else
    echo -e "\n${BLUE}Adding shell wrapper to $SHELL_RC...${NC}"

    # Backup shell config
    cp "$SHELL_RC" "${SHELL_RC}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "  ${GREEN}✓${NC} Backed up $SHELL_RC"

    # Append wrapper
    echo "" >> "$SHELL_RC"
    cat "$SCRIPT_DIR/templates/shell-wrapper.sh" >> "$SHELL_RC"
    echo -e "  ${GREEN}✓${NC} Added claude() wrapper function"
fi

# Configure Claude hooks
echo -e "\n${BLUE}Configuring Claude hooks...${NC}"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

if [[ -f "$CLAUDE_SETTINGS" ]]; then
    # Backup existing settings
    cp "$CLAUDE_SETTINGS" "${CLAUDE_SETTINGS}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "  ${GREEN}✓${NC} Backed up existing settings.json"

    # Check if jq is available for proper JSON merging
    if command -v jq &>/dev/null; then
        # Merge hooks using jq
        HOOKS_JSON=$(cat "$SCRIPT_DIR/templates/hooks.json")
        EXISTING=$(cat "$CLAUDE_SETTINGS")

        # Merge the hooks object
        echo "$EXISTING" | jq --argjson newhooks "$HOOKS_JSON" '.hooks = ($newhooks + (.hooks // {}))' > "${CLAUDE_SETTINGS}.tmp"
        mv "${CLAUDE_SETTINGS}.tmp" "$CLAUDE_SETTINGS"
        echo -e "  ${GREEN}✓${NC} Merged hooks into settings.json"
    else
        echo -e "  ${YELLOW}Warning: jq not found. Please manually add hooks to $CLAUDE_SETTINGS${NC}"
        echo -e "  ${YELLOW}See templates/hooks.json for the required configuration${NC}"
    fi
else
    # Create new settings file
    echo '{"hooks": ' > "$CLAUDE_SETTINGS"
    cat "$SCRIPT_DIR/templates/hooks.json" >> "$CLAUDE_SETTINGS"
    echo '}' >> "$CLAUDE_SETTINGS"
    echo -e "  ${GREEN}✓${NC} Created settings.json with hooks"
fi

# Optional: Install fswatch for better performance
echo -e "\n${BLUE}Checking for fswatch (optional, improves performance)...${NC}"
if command -v fswatch &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} fswatch is already installed"
else
    if command -v brew &>/dev/null; then
        echo -e "  ${YELLOW}fswatch not found. Install it for better performance?${NC}"
        read -p "  Install fswatch via Homebrew? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew install fswatch
            echo -e "  ${GREEN}✓${NC} Installed fswatch"
        else
            echo -e "  ${YELLOW}Skipped. Using polling fallback (slightly higher CPU usage)${NC}"
        fi
    else
        echo -e "  ${YELLOW}fswatch not found and Homebrew not available.${NC}"
        echo -e "  ${YELLOW}The tool will work fine using polling fallback.${NC}"
    fi
fi

# Done!
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 Installation Complete!                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "To activate, either:"
echo -e "  1. Open a ${BLUE}new terminal tab${NC}, or"
echo -e "  2. Run: ${BLUE}source $SHELL_RC${NC}"
echo ""
echo -e "Then run ${BLUE}claude${NC} in any project to see the magic! ✨"
echo ""
echo -e "Tab title format: ${YELLOW}#project #branch status${NC}"
echo -e "  ⏳ ready      - Waiting for your prompt"
echo -e "  🔄 working    - Processing your request"
echo -e "  ✓ done       - Finished"
echo -e "  ⏳ waiting    - Idle, needs attention"
echo -e "  ⚠️  permission - Needs your approval"
echo ""
