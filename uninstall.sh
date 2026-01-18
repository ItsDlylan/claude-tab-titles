#!/bin/bash
# ============================================================
# Claude Code Tab Titles - Uninstaller
# ============================================================
# Removes the tab title functionality and restores original config
# ============================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Claude Code Tab Titles - Uninstaller                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

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
        SHELL_RC="$HOME/.zshrc"
        ;;
esac

# Remove shell wrapper from config
MARKER_START="# ============================================================"
MARKER_CONTENT="# Claude Code Tab Titles - Shell Wrapper"
MARKER_END="# End Claude Code Tab Titles"

echo -e "${BLUE}Removing shell wrapper from $SHELL_RC...${NC}"

if grep -q "$MARKER_CONTENT" "$SHELL_RC" 2>/dev/null; then
    # Create a backup
    cp "$SHELL_RC" "${SHELL_RC}.backup.$(date +%Y%m%d_%H%M%S)"

    # Remove the wrapper block (everything between markers)
    # Using awk for reliable multi-line removal
    awk '
        /# ============================================================/ && /Claude Code Tab Titles - Shell Wrapper/ { skip=1; next }
        /# ============================================================/ && skip { skip=0; next }
        skip && /# End Claude Code Tab Titles/ { skip=0; next }
        !skip
    ' "$SHELL_RC" > "${SHELL_RC}.tmp"

    # Also remove with simpler pattern matching
    sed -i.bak '/# Claude Code Tab Titles - Shell Wrapper/,/# End Claude Code Tab Titles/d' "${SHELL_RC}.tmp" 2>/dev/null || true

    # Remove CLAUDE_CODE_DISABLE_TERMINAL_TITLE if it was added
    grep -v "CLAUDE_CODE_DISABLE_TERMINAL_TITLE" "${SHELL_RC}.tmp" > "${SHELL_RC}.tmp2" || cp "${SHELL_RC}.tmp" "${SHELL_RC}.tmp2"

    mv "${SHELL_RC}.tmp2" "$SHELL_RC"
    rm -f "${SHELL_RC}.tmp" "${SHELL_RC}.tmp.bak"

    echo -e "  ${GREEN}✓${NC} Removed shell wrapper"
else
    echo -e "  ${YELLOW}Shell wrapper not found in $SHELL_RC${NC}"
fi

# Remove scripts
echo -e "\n${BLUE}Removing scripts...${NC}"
SCRIPTS=(
    "title-watcher.sh"
    "set-title.sh"
    "notify-working.sh"
    "notify-idle.sh"
    "notify-permission.sh"
    "notify-stop.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [[ -f "$HOME/.claude/scripts/$script" ]]; then
        rm "$HOME/.claude/scripts/$script"
        echo -e "  ${GREEN}✓${NC} Removed $script"
    fi
done

# Clean up any leftover title files
echo -e "\n${BLUE}Cleaning up title files...${NC}"
rm -f "$HOME/.claude/current-title"*
echo -e "  ${GREEN}✓${NC} Removed title files"

# Note about hooks
echo -e "\n${YELLOW}Note: Claude hooks in ~/.claude/settings.json were not removed.${NC}"
echo -e "To remove them manually, edit the file and remove the hooks that reference:"
echo -e "  - notify-working.sh"
echo -e "  - notify-stop.sh"
echo -e "  - notify-idle.sh"
echo -e "  - notify-permission.sh"

# Done!
echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║               Uninstallation Complete!                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "To complete removal, either:"
echo -e "  1. Open a ${BLUE}new terminal tab${NC}, or"
echo -e "  2. Run: ${BLUE}source $SHELL_RC${NC}"
echo ""
