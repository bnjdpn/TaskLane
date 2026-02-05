<p align="center">
  <img src="docs/assets/images/icon.png" alt="TaskLane" width="128" height="128">
</p>

<h1 align="center">TaskLane</h1>

<p align="center">
  <strong>A Windows-style taskbar for macOS</strong><br>
  Perfect for Windows users transitioning to Mac
</p>

<p align="center">
  <a href="https://github.com/bnjdpn/TaskLane/releases/latest">
    <img src="https://img.shields.io/github/v/release/bnjdpn/TaskLane?style=flat-square" alt="Latest Release">
  </a>
  <a href="https://github.com/bnjdpn/TaskLane/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/bnjdpn/TaskLane?style=flat-square" alt="License">
  </a>
  <a href="https://github.com/bnjdpn/TaskLane/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/bnjdpn/TaskLane/build.yml?style=flat-square" alt="Build Status">
  </a>
  <a href="https://codecov.io/gh/bnjdpn/TaskLane">
    <img src="https://img.shields.io/codecov/c/github/bnjdpn/TaskLane?style=flat-square" alt="Coverage">
  </a>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#building">Building</a> •
  <a href="#license">License</a>
</p>

---

## Features

- **Windows 11 Style** - Familiar taskbar design for Windows users
- **Window Thumbnails** - Hover over apps to see window previews
- **Focus Individual Windows** - Click to focus a specific window, not just the app
- **Multi-Monitor Support** - One taskbar per screen
- **Space Awareness** - Shows only windows from the current desktop/Space
- **Pinned Apps** - Keep your favorite apps always visible
- **System Tray** - Clock with date display
- **Customizable** - Position, size, blur effect, and more

## Installation

### Download

Download the latest DMG from [**Releases**](https://github.com/bnjdpn/TaskLane/releases/latest)

1. Open the DMG file
2. Drag TaskLane to your Applications folder
3. Launch TaskLane
4. **Right-click > Open** on first launch (app is not notarized)

## Usage

### First Launch

1. Grant **Screen Recording** permission when prompted (for window thumbnails)
2. Grant **Accessibility** permission when prompted (for window control)
3. The taskbar appears at the bottom of your screen

### Customization

Click the TaskLane icon in the menu bar and select **Settings** to customize:

- **Position** - Bottom, Top, Left, or Right
- **Size** - Adjust taskbar height
- **Appearance** - Blur effect, themes
- **Clock** - Show/hide date
- **Layout** - Center icons like Windows 11

### Tips for Windows Users

| Windows | TaskLane |
|---------|----------|
| Win + D | Click empty area (coming soon) |
| Hover taskbar | See window thumbnails |
| Click app | Focus the app |
| Right-click app | Context menu with Quit, Hide, etc. |
| Pin to taskbar | Right-click > Pin |

## Requirements

- macOS 14.0 (Sonoma) or later
- Screen Recording permission (optional, for thumbnails)
- Accessibility permission (optional, for window control)

## Building from Source

```bash
# Clone the repository
git clone https://github.com/bnjdpn/TaskLane.git
cd TaskLane

# Build
swift build -c release

# Run
swift run
```

## Comparison with Alternatives

| Feature | TaskLane | uBar ($30) | Taskbar ($25) |
|---------|----------|------------|---------------|
| Price | **Free** | $30 | $25 |
| Window thumbnails | Yes | Yes | Yes |
| Focus individual windows | Yes | Yes | Yes |
| Multi-monitor | Yes | Yes | Yes |
| Space filtering | Yes | No | Yes |
| Auto-resize windows | Yes | No | Yes |
| Open source | **Yes** | No | No |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE) - Free to use, modify, and distribute.

---

<p align="center">
  Made with love for Windows refugees on Mac
</p>
