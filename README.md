# hidecursor

A tiny macOS background daemon that hides the mouse cursor when it's been idle for a couple of seconds. Comes back on the next mouse movement, click, or scroll.

## What it does

- 🫥 Cursor disappears after 2 seconds of inactivity.
- 👀 Reappears on `mouseMoved`, mouse-down, or `scrollWheel`.

No UI — no Dock icon, no menu bar item. Stop it via `launchctl bootout`.

## Requirements

- macOS 11+
- Xcode command line tools (`xcode-select --install`) — provides `swiftc`.
- [`just`](https://github.com/casey/just) — `brew install just`.
- Accessibility permission for the binary (granted on first run; macOS will prompt).

## Quick start

```sh
just install        # build hidecursor.app and copy it to /Applications
just agent-install  # auto-start at login via launchd
```

## All recipes

```
just build            Build hidecursor.app in the project directory
just install          Build, then copy hidecursor.app to /Applications
just uninstall        Remove hidecursor.app from /Applications
just run              Run the script directly (skips bundle build)
just agent-install    Install the LaunchAgent so hidecursor starts at login
just agent-restart    Restart the LaunchAgent (use after rebuilding)
just agent-uninstall  Uninstall the LaunchAgent
just clean            Remove build artifacts
```

## Notes

- `LSUIElement` is set, so there's no Dock icon and no menu bar UI.
- The bundle is ad-hoc codesigned (`codesign --sign -`).
- macOS will prompt for Accessibility permission on first launch — required to monitor global mouse events.
