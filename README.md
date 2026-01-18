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

### File Structure

```
~/.claude/
├── scripts/
│   ├── title-helper.sh      # Core: config loading, ticket detection, title building
│   ├── title-watcher.sh     # Background process watching for title changes
│   ├── set-title.sh         # Manual title setter (for custom scripts)
│   ├── notify-working.sh    # Hook: triggered when you submit a prompt
│   ├── notify-stop.sh       # Hook: triggered when Claude finishes
│   ├── notify-idle.sh       # Hook: triggered after 60s of inactivity
│   └── notify-permission.sh # Hook: triggered when Claude needs approval
├── tab-titles.conf          # Your configuration file
├── settings.json            # Claude Code settings (includes hooks)
└── current-title-*          # Session-specific title files (temporary)
```

### Deep Dive: How It All Works

#### 1. The Shell Wrapper (`claude()` function)

When you type `claude` in your terminal, you're not running the Claude binary directly. Instead, a wrapper function intercepts the command:

```bash
claude() {
    # 1. Capture the terminal's unique TTY identifier
    local tty_id=$(tty | tr '/' '_')  # /dev/ttys001 → _dev_ttys001
    export CLAUDE_TTY_ID="$tty_id"     # Pass to child processes (hooks)

    # 2. Create a session-specific title file
    local title_file="$HOME/.claude/current-title-$tty_id"

    # 3. Set initial "ready" state
    echo "#$project #$branch ⏳ ready" > "$title_file"

    # 4. Start the title watcher in the background
    ~/.claude/scripts/title-watcher.sh "$tty_id" &

    # 5. Run the actual Claude binary
    /path/to/claude "$@"

    # 6. Cleanup when Claude exits
    kill $watcher_pid
    rm -f "$title_file"
}
```

**Why a wrapper?** Claude Code doesn't natively support custom tab titles. The wrapper lets us set up the environment before Claude starts and clean up after it exits.

#### 2. The Title Watcher (`title-watcher.sh`)

This script runs in the background for the entire Claude session, watching for changes to the title file:

```bash
# Using fswatch (instant updates)
fswatch -o "$TITLE_FILE" | while read; do
    title=$(cat "$TITLE_FILE")
    printf '\033]0;%s\007' "$title"  # ANSI escape sequence to set terminal title
done

# Or polling fallback (if fswatch not installed)
while true; do
    title=$(cat "$TITLE_FILE")
    printf '\033]0;%s\007' "$title"
    sleep 1
done
```

**Why watch a file?** Claude's hooks run in subprocesses that can't directly control the parent terminal. By writing to a file that the watcher monitors, we bridge this gap.

#### 3. The Configuration System (`title-helper.sh`)

This is the brain of the operation. All notify scripts source this file to get shared functionality:

```bash
# Every notify script is just:
source "$HOME/.claude/scripts/title-helper.sh"
write_title "working"  # or "done", "waiting", "permission"
```

The helper provides:

- **`load_config()`** - Reads `~/.claude/tab-titles.conf` and sets defaults
- **`get_project()`** - Gets project name (from `.claude-project` file or directory name)
- **`get_branch()`** - Gets current git branch
- **`get_ticket()`** - Detects ticket ID based on configured source (branch/env/file)
- **`build_title()`** - Assembles the final title string from your format template
- **`write_title()`** - Writes to the session-specific title file

**Why a shared helper?** Separation of concerns. The notify scripts focus on *when* to update (the trigger), while the helper handles *what* to update (the logic). This means you can change your title format without touching the hook scripts.

#### 4. Claude Code Hooks

Claude Code has a hook system that runs shell commands on specific events. We configure these in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [{ "command": "~/.claude/scripts/notify-working.sh" }],
    "Stop": [{ "command": "~/.claude/scripts/notify-stop.sh" }],
    "Notification": [
      { "matcher": "idle_prompt", "command": "~/.claude/scripts/notify-idle.sh" },
      { "matcher": "permission_prompt", "command": "~/.claude/scripts/notify-permission.sh" }
    ]
  }
}
```

| Event | Trigger | Script |
|-------|---------|--------|
| `UserPromptSubmit` | You press Enter to send a prompt | `notify-working.sh` |
| `Stop` | Claude finishes responding | `notify-stop.sh` |
| `Notification` (idle) | Claude idle for 60+ seconds | `notify-idle.sh` |
| `Notification` (permission) | Claude needs tool approval | `notify-permission.sh` |

#### 5. Ticket Detection

The `get_ticket()` function supports multiple detection methods:

**Branch Parsing (default):**
```bash
branch="feature/ENG-123-add-login"
pattern="[A-Z]+-[0-9]+"
ticket=$(echo "$branch" | grep -oE "$pattern" | head -1)
# Result: ENG-123
```

**Environment Variable:**
```bash
# In your .envrc or shell
export CLAUDE_TICKET="ENG-123"

# title-helper.sh reads it
ticket="${!TICKET_ENV_VAR}"  # Indirect variable expansion
```

**File-based:**
```bash
# In your project: echo "ENG-123" > .ticket
ticket=$(cat "$TICKET_FILE")
```

#### 6. Why TTY for Session Isolation?

Each terminal tab gets assigned a unique TTY (teletypewriter) device by the operating system:

```
Tab 1: /dev/ttys001
Tab 2: /dev/ttys002
Tab 3: /dev/ttys003
```

We transform this into a safe filename: `/dev/ttys001` → `_dev_ttys001`

**Why TTY?**
- **Unique per tab** - Each tab has its own TTY, guaranteed by the OS
- **Survives the session** - Same TTY from start to finish of Claude
- **Available everywhere** - Both the wrapper AND the hooks can access it
- **No coordination needed** - No need to generate/track session IDs

**The Problem It Solves:**

Without per-session isolation, all Claude instances would write to the same file:

```
# BAD: Shared file
Tab 1 writes: "#ProjectA #main 🔄 working"
Tab 2 writes: "#ProjectB #feature ✓ done"    # Overwrites Tab 1!
Both tabs show: "#ProjectB #feature ✓ done"  # Wrong!
```

With TTY-based isolation:

```
# GOOD: Separate files
Tab 1 writes to: ~/.claude/current-title-_dev_ttys001
Tab 2 writes to: ~/.claude/current-title-_dev_ttys002
Each tab shows its own status correctly!
```

### Lifecycle of a Title Update

Here's the complete flow when you submit a prompt:

```
1. You type a prompt and press Enter
         │
         ▼
2. Claude Code fires "UserPromptSubmit" hook
         │
         ▼
3. notify-working.sh runs
         │
         ▼
4. sources title-helper.sh
   ├── load_config() reads ~/.claude/tab-titles.conf
   ├── get_project() → "MyApp"
   ├── get_branch() → "feature/ENG-123-task"
   ├── get_ticket() → "ENG-123" (extracted from branch)
   └── build_title("working") → "ENG-123 #feature 🔄 working"
         │
         ▼
5. write_title() writes to ~/.claude/current-title-_dev_ttys001
         │
         ▼
6. title-watcher.sh detects file change (via fswatch or polling)
         │
         ▼
7. Sends ANSI escape: printf '\033]0;ENG-123 #feature 🔄 working\007'
         │
         ▼
8. Terminal updates tab title ✨
```

Total time: ~10-50ms (instant with fswatch, up to 1s with polling)

## Claude Code Skills Integration

[Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/tutorials/custom-slash-commands) are custom slash commands that extend Claude's capabilities. You can create skills to rename your terminal tab on-demand or integrate tab renaming into your existing workflow skills.

### Creating a `/name-tab` Skill

Create the skill file at `.claude/skills/name-tab/SKILL.md` in your project (or `~/.claude/skills/name-tab/SKILL.md` for global access):

```markdown
---
name: name-tab
description: Rename the terminal tab with #project #branch #task pattern.
---

# Name Terminal Tab

Rename the current terminal tab/window with a clear, identifiable pattern.

**Format:** `#project #branch #task`

**Arguments:** `$ARGUMENTS` (optional: task description)

---

## Steps to Execute

### Step 1: Detect Project Name

Get the project name from the current working directory:

\`\`\`bash
basename "$(pwd)"
\`\`\`

If in a worktree, extract the main project name.

### Step 2: Detect Current Branch

\`\`\`bash
git branch --show-current 2>/dev/null || echo "no-git"
\`\`\`

Simplify long branch names:
- `feature/card-search` → `card-search`
- `fix/bug-123` → `bug-123`

### Step 3: Determine Task Description

If `$ARGUMENTS` was provided, use it as the task.

Otherwise, ask the user:
> "What task are you working on? (1-3 words, use hyphens)"

### Step 4: Update Terminal Title

Write the title to the watcher file:

\`\`\`bash
~/.claude/scripts/set-title.sh "#PROJECT #BRANCH #TASK"
\`\`\`

Replace PROJECT, BRANCH, and TASK with actual values.

### Step 5: Confirm to User

Display:

\`\`\`
✅ Tab renamed: #PokemonTCG #develop #fixing-tests
\`\`\`

---

## Examples

| Command | Result |
|---------|--------|
| `/name-tab` | Asks for task, then sets title |
| `/name-tab debugging` | Sets to `#project #branch #debugging` |
| `/name-tab price-scraper` | Sets to `#project #branch #price-scraper` |
```

### Integrating Tab Naming into Workflow Skills

If you have workflow skills that set up development environments (like git worktrees, database resets, or feature branches), you can add automatic tab renaming as a final step.

**Example: Adding to a worktree/feature setup skill**

Add this step at the end of your existing workflow skill:

```markdown
### Step N: Rename Terminal Tab

Automatically rename the terminal tab to reflect the new work context:

1. Extract the task name from the branch (e.g., `feature/card-search` → `card-search`)
2. Get the project name from the directory
3. Call the title script:

\`\`\`bash
~/.claude/scripts/set-title.sh "#PROJECT #BRANCH #TASK"
\`\`\`

This happens automatically - no user input needed.
```

**Why integrate vs. chain skills?**

Claude Code skills run independently - you can't chain them like `/tier2 /name-tab`. By integrating tab renaming directly into your workflow skill, the rename happens automatically as part of the setup process.

### Adding to CLAUDE.md

If you don't use skills, you can add instructions to your project's `CLAUDE.md` file to have Claude rename tabs when starting work:

```markdown
## Terminal Tab Naming

When starting any new task or feature work, automatically rename the terminal tab:

1. Extract the project name from the current directory
2. Get the current git branch
3. Ask the user for a short task description (1-3 words, use hyphens)
4. Run: `~/.claude/scripts/set-title.sh "#PROJECT #BRANCH #TASK"`

Example: `~/.claude/scripts/set-title.sh "#MyApp #develop #auth-refactor"`
```

This ensures Claude will rename your tab whenever you start a new conversation about a task.

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
