# Claude Code Tab Titles 🏷️

Automatic terminal tab titles for [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) showing your project, git branch, and current status.

![Tab Title Demo](https://via.placeholder.com/600x100?text=%23MyProject+%23main+%E2%9C%93+done)

## Features

- **Smart tab titles** - Shows `#project #branch status` in your terminal tab
- **Real-time status** - See at a glance if Claude is working, done, or needs attention
- **Multi-session support** - Run Claude in multiple tabs without conflicts
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
git clone https://github.com/YOUR_USERNAME/claude-tab-titles.git
cd claude-tab-titles
./install.sh
```

### What it does

1. Copies scripts to `~/.claude/scripts/`
2. Adds a `claude()` wrapper function to your `.zshrc` or `.bashrc`
3. Configures Claude Code hooks in `~/.claude/settings.json`
4. Optionally installs `fswatch` for better performance

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
Tab 2: ~/.claude/current-title-_dev_ttys002  →  "#ProjectB #feature ✓ done"
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
┌─────────────────────┐
│  current-title-TTY  │  ← Session-specific file
└──────────┬──────────┘
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

## Customization

### Change the title format

Edit `~/.claude/scripts/notify-*.sh` to customize the title format. For example, to show full project path:

```bash
# In notify-working.sh
project="$PWD"  # Full path instead of basename
```

### Disable notifications

Remove the `osascript` line from the notify scripts to disable macOS notifications.

### Disable terminal bell

Remove the `printf '\a'` line from the notify scripts.

## Troubleshooting

### Tab title not updating

1. Make sure you opened a **new terminal tab** after installation
2. Check that Claude Code is using the wrapper: `type claude` should show the function
3. Verify scripts exist: `ls ~/.claude/scripts/`

### Multiple tabs showing same status

This shouldn't happen with the per-session isolation. Check that:
1. The `CLAUDE_TTY_ID` environment variable is being set
2. Title files are unique: `ls ~/.claude/current-title-*`

### Notifications not working

macOS notifications require permission. Check System Preferences → Notifications → Script Editor.

## Contributing

Pull requests welcome! Some ideas:

- [ ] Linux support
- [ ] Windows support (WSL)
- [ ] Customizable status icons
- [ ] Support for other shells (fish, etc.)

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

Built with ❤️ for the Claude Code community.
