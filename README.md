# FOV-TP

A SourceMod plugin for Team Fortress 2 that allows players to customize their Field of View (FOV) and toggle between first-person and third-person camera views with persistent settings.

[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

FOV-TP is a SourceMod plugin designed to enhance player experience in Team Fortress 2 by providing customizable camera controls. Players can set their preferred FOV within a safe range and switch between first-person and third-person perspectives, with all preferences saved using SourceMod's cookie system for persistence across sessions.

The plugin addresses the common player request for camera customization in TF2 servers, particularly useful for community servers that want to offer enhanced player agency. It uses SourceMod's client preferences (cookies) to store settings per-player and automatically reapplies them on spawn and class change.

### Key Responsibilities

- **FOV Management**: Allows players to set custom Field of View values between 20 and 200, with intelligent clamping and validation
- **Camera Perspective**: Enables toggling between first-person and third-person camera views using forced taunt cam mechanics
- **Persistence**: Saves player preferences using SourceMod cookies and automatically restores them across sessions and respawns
- **Event Handling**: Monitors player spawn and class change events to reapply saved settings automatically

## Features

- **Custom FOV Settings**: Players can set FOV values between 20-200 using `sm_fov` or `fov` commands
- **FOV Reset**: Reset FOV to client's default settings by using the command without arguments
- **Third-Person Toggle**: Use `sm_tp` to enable third-person camera view
- **First-Person Toggle**: Use `sm_fp` to return to first-person view
- **Persistent Preferences**: All settings are saved per-player using SourceMod's cookie system
- **Automatic Reapplication**: Settings are restored on player spawn and class changes
- **Safe Clamping**: FOV values are automatically clamped to safe ranges to prevent exploits
- **Console Protection**: Commands blocked from server console, player-only execution

## Prerequisites

- SourceMod 1.10+ installed on your Team Fortress 2 server
- Team Fortress 2 dedicated server
- ClientPrefs extension enabled in SourceMod

## Installation

1. Download the compiled plugin or compile `FOTP.sp` using the SourceMod compiler
2. Copy `FOTP.smx` to your server's `addons/sourcemod/plugins/` directory
3. Restart the server or use `sm plugins load FOTP` to load the plugin
4. The plugin will automatically create necessary cookies and register commands

## Configuration

The plugin uses SourceMod's cookie system for storing player preferences. No additional configuration files are needed.

### Commands

| Command          | Description                 | Usage                            |
| ---------------- | --------------------------- | -------------------------------- |
| `sm_fov [value]` | Set FOV or reset to default | `sm_fov 90` or `sm_fov` to reset |
| `fov [value]`    | Alias for sm_fov            | `fov 120`                        |
| `sm_tp`          | Enable third-person view    | `sm_tp`                          |
| `sm_fp`          | Enable first-person view    | `sm_fp`                          |

### Constants

| Constant      | Value | Description               |
| ------------- | ----- | ------------------------- |
| `MIN_FOV`     | 20    | Minimum allowed FOV value |
| `MAX_FOV`     | 200   | Maximum allowed FOV value |
| `DEFAULT_FOV` | 90    | Default FOV when reset    |

## Development

### Project Structure

```
FOV-TP/
├── scripting/
│   └── FOTP.sp              # Main plugin source code
├── LICENSE                  # MIT License
└── README.md                # This file
```

### Building

To compile the plugin:

```bash
spcomp FOTP.sp
```

The compiled `.smx` file will be placed in the `compiled/` directory.

## License

See [LICENSE](LICENSE) file for details.
