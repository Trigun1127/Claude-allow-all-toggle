# Claude Permissions Toggle

A Windows GUI for controlling Claude Code permissions with category-based auto-approval, destructive-command blocking, fast write/edit handling, and a compact minimal mode.

![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=windows&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.x-blue?style=flat&logo=python&logoColor=white)

## Features

- Auto-registers Claude Code hooks when opened
- Removes hook registration when closed or turned OFF
- Fast `Write` / `Edit` / `NotebookEdit` handling while W/E is enabled
- Two approval styles: `Silent` and `Show accepts`
- Category-based ALLOW toggles
- Pattern-based BLOCK toggles for destructive commands
- PowerShell-aware shell filtering
- Saved custom templates
- Minimal mode for quick ON/OFF control

## Requirements

- Windows 10 or 11
- Python 3.x
- Claude Code CLI

## Quick Start

```bash
git clone https://github.com/Trigun1127/Claude-allow-all-toggle.git
cd Claude-allow-all-toggle
```

Launch the app by opening `AutoYesToggle.pyw`.

Notes:

- No installer is required
- The app registers the Claude hooks automatically when it opens
- If Claude Code was already running, restart it once or review the hook change in `/hooks`
- If multiple Python installations exist, the one used to launch `AutoYesToggle.pyw` is the one used by the hook

## Taskbar Shortcut

To create a desktop shortcut that can be pinned to the taskbar:

```powershell
powershell -ExecutionPolicy Bypass -File create_shortcut.ps1
```

Then:

1. Right-click the new `Claude Permissions` shortcut on the desktop
2. Choose `Pin to taskbar`
3. Delete the desktop shortcut if it is no longer needed

## Main Modes

The app supports two main approval flows:

- `Silent`: approved tools run without showing Claude's permission UI
- `Show accepts`: Claude shows the permission UI, then the hook auto-accepts it

`Show accepts` is useful when the inline diff preview is helpful. `Silent` is the cleaner workflow when no prompt or diff view is desired.

## Minimal Mode

Click `_` in the main window to collapse into minimal mode.

Minimal mode shows:

- `...` to expand back to the full window
- `✎` to toggle fast `Write` / `Edit` / `NotebookEdit`
- The current template button such as `ALL*` or `CUSTOM`

Minimal mode does not show the approval-style control. `Silent` and `Show accepts` stay available in the main window only.

## What OFF, ALL*, ALL, and CUSTOM Do

| Button | Behavior |
|------|------|
| `OFF` | Claude uses its normal permission behavior |
| `ALL*` | Broad auto-approval with destructive patterns still blocked |
| `ALL` | Broad auto-approval including destructive commands |
| `CUSTOM` | Loads the saved custom checkbox state |

Use `Save` to store the current custom checkbox state.

## How Permissions Work

The app combines two layers:

1. `ALLOW`: categories that can be auto-approved
2. `BLOCK`: specific dangerous patterns that are always denied

Example:

- `Git` can be allowed in general
- `git push --force` can still be blocked

## Write/Edit Fast Path

When W/E is ON, the app temporarily adds these Claude permissions while the toggle is active:

- `Write`
- `Edit`
- `NotebookEdit`

That avoids the prompt flash on recent Claude Code builds. Turning W/E OFF or closing the app removes only the managed rules added by the app.

## Category Mapping

| Category | Claude tools |
|------|------|
| Read files | `Read` |
| Write files | `Write` |
| Edit files | `Edit` |
| Search | `Glob`, `Grep`, `LSP`, `MCPSearch`, `ToolSearch`, `ListMcpResourcesTool` |
| Web access | `WebFetch`, `WebSearch` |
| Notebook edit | `NotebookEdit` |
| Task tools | `Agent`, `Task`, `TodoWrite`, `AskUserQuestion`, `ExitPlanMode`, `Skill`, `TaskCreate`, `TaskUpdate`, `TaskList`, `TaskGet`, `TaskOutput`, `EnterPlanMode`, `EnterWorktree`, `ExitWorktree`, `CronCreate`, `CronDelete`, `CronList`, `SendMessage`, `TeamCreate`, `TeamDelete`, `TaskStop` |
| Bash safe | safe Bash and PowerShell commands such as `npm`, `node`, `python`, `ls`, `Get-ChildItem`, `Get-Content`, `Select-String` |
| Bash delete | `rm`, `del`, `rmdir`, `rd`, `erase`, `unlink`, `shred`, `Remove-Item`, `ri` |
| Bash all | `Bash`, `BashOutput`, `KillShell`, `Monitor`, `PowerShell` |
| Git | any Bash or PowerShell command containing `git` |

## Special Overrides

### Git override

If `git` is OFF, git commands still ask for permission even if `bash_all` is ON.

### File deletion override

If `bash_delete` is OFF, file-deletion commands still ask for permission even if `bash_all` is ON.

Detected delete commands include:

- `rm`
- `del`
- `rmdir`
- `rd`
- `erase`
- `unlink`
- `shred`
- `Remove-Item`
- `ri`

This also applies to chained commands such as:

```bash
npm run build && rm -r dist
ls -la; rm old.txt
```

## Blocked Patterns

The default BLOCK list covers:

- `rm -rf`
- `rm -rf /` or home-directory deletes
- `git reset --hard`
- `git checkout --`
- `git clean -f`
- `git push --force`
- `git branch -D`
- `git stash drop` / `git stash clear`
- `find -delete`
- `xargs` or `parallel` with delete commands
- `dd if=`
- `mkfs`
- `chmod -R 777 /`

## Config Files

The app uses two files:

- `~/.claude-permissions.json`
- `~/.claude/settings.json`

`~/.claude-permissions.json` stores saved state such as the active template, minimal mode, W/E state, approval mode, and saved custom settings.

`~/.claude/settings.json` stores the active Claude hook registration and temporary `permissions.allow` entries while W/E is ON.

## Troubleshooting

### Hook error after a Claude Code update

If every tool suddenly starts asking for permission or Claude shows a hook error:

1. Pull the latest repo changes
2. Close and reopen `AutoYesToggle.pyw`, or run `python install.py`
3. Restart Claude Code

The hook command in `~/.claude/settings.json` should use quoted forward-slash paths, for example:

```json
"command": "\"C:/Users/.../python.exe\" \"C:/Users/.../claude-permissions-hook.py\""
```

### Write/Edit still prompts

If `Write` or `Edit` still prompts:

1. Reopen `AutoYesToggle.pyw`
2. Start a fresh Claude Code session
3. Confirm both hook events exist in `~/.claude/settings.json`
4. Confirm `Write`, `Edit`, and `NotebookEdit` are present in `permissions.allow` while W/E is ON

### Claude shows an error label even though permissions work

This is a known Claude Code cosmetic issue:

[Claude Code issue #17088](https://github.com/anthropics/claude-code/issues/17088)

## Uninstall

Closing the app is enough for normal use because the hook is removed when the app closes or is turned OFF.

To remove the project configuration:

```bash
python install.py --uninstall
python install.py --uninstall --full
```

## License

MIT
