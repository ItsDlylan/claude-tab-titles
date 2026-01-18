# Claude Code Tab Titles 🏷️

Automatic terminal tab titles for [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) showing your project, git branch, ticket ID, and current status.

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ #MyProject #main ⏳ ready │ ENG-123 #feature 🔄 working │ #App #dev ✓ done  │
└──────────────────────────────────────────────────────────────────────────────┘
  Tab 1: Waiting for input     Tab 2: Working on ticket      Tab 3: Task complete
```

## Features

- **Smart tab titles** - Shows `#project #branch status` in your terminal tab
- **Ticket integration** - Show Linear, Jira, Trello, Asana, or any ticket ID
- **Real-time status** - See at a glance if Claude is working, done, or needs attention
- **Multi-session support** - Run Claude in multiple tabs without conflicts
- **Fully customizable** - Configure format, icons, notifications, and more
- **macOS notifications** - Get notified when Claude needs your input
- **Works everywhere** - Ghostty, iTerm2, Terminal.app, Kitty, Alacritty, etc.

## Status Indicators

| Status | Icon | Meaning |
|--------|------|---------|
| ready | ⏳ | Waiting for your first prompt |
| working | 🔄 | Processing your request |
| done | ✓ | Finished responding |
| waiting | ⏳ | Idle for 60+ seconds, needs attention |
| permission | ⚠️ | Needs your approval to continue |

## Installation

### Quick Install

```bash
git clone https://github.com/ItsDlylan/claude-tab-titles.git
cd claude-tab-titles
./install.sh
```

### What it does

1. Copies scripts to `~/.claude/scripts/`
2. Creates config file at `~/.claude/tab-titles.conf`
3. Adds a `claude()` wrapper function to your `.zshrc` or `.bashrc`
4. Configures Claude Code hooks in `~/.claude/settings.json`
5. Optionally installs `fswatch` for better performance

## Configuration

All configuration is in `~/.claude/tab-titles.conf`. Edit this file to customize your setup.

### Title Format

Customize how your tab title appears using variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `$PROJECT` | Current directory name | MyApp |
| `$BRANCH` | Current git branch | main |
| `$TICKET` | Ticket ID (see below) | ENG-123 |
| `$STATUS` | Current status with icon | 🔄 working |

```bash
# Default format
TITLE_FORMAT="#\$PROJECT #\$BRANCH \$STATUS"
# Output: #MyApp #main 🔄 working

# With ticket
TITLE_FORMAT="\$TICKET #\$BRANCH \$STATUS"
# Output: ENG-123 #main 🔄 working

# Minimal
TITLE_FORMAT="\$TICKET \$STATUS"
# Output: ENG-123 🔄 working

# Full info
TITLE_FORMAT="#\$PROJECT #\$BRANCH \$TICKET \$STATUS"
# Output: #MyApp #main ENG-123 🔄 working
```

### Ticket Integration

Show ticket IDs from Linear, Jira, Trello, Asana, or any project management tool.

#### Option 1: Extract from Branch Name (Default)

If your branches are named like `feature/ENG-123-add-login`, the ticket is extracted automatically:

```bash
TICKET_SOURCE="branch"
TICKET_PATTERN="[A-Z]+-[0-9]+"  # Matches ENG-123, PROJ-456, etc.
```

**Common patterns:**

| Tool | Pattern | Example Branch | Extracts |
|------|---------|----------------|----------|
| Linear/Jira | `[A-Z]+-[0-9]+` | feature/ENG-123-login | ENG-123 |
| GitHub Issues | `#[0-9]+` | fix/#456-bug | #456 |
| Shortcut | `sc-[0-9]+` | feature/sc-12345-task | sc-12345 |
| Asana | `[0-9]{10,}` | task/1234567890123 | 1234567890123 |
| Trello | `[0-9]+-` | 123-card-name | 123 |

#### Option 2: Environment Variable

Set a `CLAUDE_TICKET` environment variable (great with [direnv](https://direnv.net/)):

```bash
TICKET_SOURCE="env"
TICKET_ENV_VAR="CLAUDE_TICKET"
```

In your project's `.envrc`:
```bash
export CLAUDE_TICKET="ENG-123"
```

#### Option 3: Project File

Create a `.ticket` file in your project root:

```bash
TICKET_SOURCE="file"
TICKET_FILE=".ticket"
```

```bash
# In your project root
echo "ENG-123" > .ticket
```

#### Option 4: Disable Tickets

```bash
TICKET_SOURCE="none"
```

### Status Icons

Customize the emoji/icons for each status:

```bash
ICON_READY="⏳"
ICON_WORKING="🔄"
ICON_DONE="✓"
ICON_WAITING="⏳"
ICON_PERMISSION="⚠️"

# Or use text only
ICON_READY=""
ICON_WORKING=""
# etc.
```

### Notifications

Enable or disable macOS notifications and terminal bell:

```bash
# macOS notifications
NOTIFY_IDLE="true"
NOTIFY_PERMISSION="true"
NOTIFY_STOP="true"

# Terminal bell (for Ghostty attention indicator, etc.)
BELL_IDLE="true"
BELL_PERMISSION="true"
BELL_STOP="true"
```

### Per-Project Overrides

Create a `.claude-project` file in any directory to override the project name:

```bash
echo "My Custom Name" > .claude-project
```

## Requirements

- macOS (Linux support coming soon)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- zsh or bash shell

### Optional

- **fswatch** - For instant title updates (falls back to polling if not installed)
  ```bash
  brew install fswatch
  ```
- **jq** - For automatic hooks configuration (manual setup if not available)
  ```bash
  brew install jq
  ```

## Uninstallation

```bash
cd claude-tab-titles
./uninstall.sh
```

## How It Works

### Per-Session Isolation

Each terminal tab has a unique TTY (e.g., `/dev/ttys001`). The tool uses this as a session identifier so multiple Claude instances don't interfere with each other:

```
Tab 1: ~/.claude/current-title-_dev_ttys001  →  "#ProjectA #main 🔄 working"
Tab 2: ~/.claude/current-title-_dev_ttys002  →  "ENG-456 #feature ✓ done"
```

### Architecture

```
┌─────────────────────┐
│   claude() wrapper  │  ← Starts session, sets initial "ready" state
│   in .zshrc         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐     ┌─────────────────────┐
│   title-watcher.sh  │────▶│  Terminal Tab Title │
│   (background)      │     │  via ANSI escape    │
└──────────┬──────────┘     └─────────────────────┘
           │
           │ watches
           ▼
┌─────────────────────┐     ┌─────────────────────┐
│  current-title-TTY  │◀────│  tab-titles.conf    │
│  (session file)     │     │  (configuration)    │
└──────────┬──────────┘     └─────────────────────┘
           │
           │ written by
           ▼
┌─────────────────────┐
│   Claude Hooks      │
│   - UserPromptSubmit│  → notify-working.sh
│   - Stop            │  → notify-stop.sh
│   - Notification    │  → notify-idle.sh
│                     │  → notify-permission.sh
└─────────────────────┘
```

## Troubleshooting

### Tab title not updating

1. Make sure you opened a **new terminal tab** after installation
2. Check that Claude Code is using the wrapper: `type claude` should show the function
3. Verify scripts exist: `ls ~/.claude/scripts/`

### Multiple tabs showing same status

This shouldn't happen with the per-session isolation. Check that:
1. The `CLAUDE_TTY_ID` environment variable is being set
2. Title files are unique: `ls ~/.claude/current-title-*`

### Ticket not showing

1. Check `TICKET_SOURCE` in your config matches your setup
2. For branch parsing, verify your branch name matches `TICKET_PATTERN`
3. Test the pattern: `echo "your-branch-name" | grep -oE "YOUR_PATTERN"`

### Notifications not working

macOS notifications require permission. Check System Preferences → Notifications → Script Editor.

## Contributing

Pull requests welcome! Some ideas:

- [ ] Linux support
- [ ] Windows support (WSL)
- [ ] Support for other shells (fish, etc.)
- [ ] More ticket pattern presets
- [ ] Integration with ticket APIs for title enrichment

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

Built with ❤️ for the Claude Code community.
