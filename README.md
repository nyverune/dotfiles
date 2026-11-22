<div align="center">

# 🌌 Nyverune Dotfiles

**A minimalist, dynamic, and aesthetic Wayland desktop environment powered by Hyprland, Quickshell, and Arch Linux.**

[![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Compositor-Hyprland-00B0FF?style=for-the-badge&logo=hyprland&logoColor=white)](https://hypr.land)
[![Shell](https://img.shields.io/badge/Shell-Zsh-F1502F?style=for-the-badge&logo=zsh&logoColor=white)](https://www.zsh.org/)
[![GNU Stow](https://img.shields.io/badge/Manager-GNU%20Stow-4EAA25?style=for-the-badge&logo=gnu&logoColor=white)](https://www.gnu.org/software/stow/)
[![Pywal](https://img.shields.io/badge/Theming-Pywal-A855F7?style=for-the-badge)](https://github.com/dylanaraps/pywal)

---

</div>

## 📑 Table of Contents

- [Key Features](#-key-features)
- [System Components](#-system-components)
- [Repository Structure](#-repository-structure)
- [Installation & Automated Setup](#-installation--automated-setup)
  - [1. Clone the repository](#1-clone-the-repository)
  - [2. Run the installer](#2-run-the-installer)
  - [CLI Flags & Options](#cli-flags--options)
- [Package Lists](#-package-lists)
- [Keybindings](#-keybindings)
- [Nyverune Theme Engine](#-nyverune-theme-engine)
- [Custom Utilities & Scripts](#-custom-utilities--scripts)

---

## ✨ Key Features

- **Declarative Symlink Farm via GNU Stow**: All configurations are neatly modularized and ready to deploy seamlessly into `$HOME`.
- **Automated Installer & Verification Script (`setup.sh`)**: Dynamically verifies core tools, dependencies, and optional extras before deploying symlinks.
- **Dynamic Theming Engine**: Integrated with `pywal` via `nyverune-theme` to synchronize colors across Kitty, Neovim, Rofi, Mako, Quickshell, Zen Browser, and Spicetify.
- **Native Wayland Status Bar & Widgets**: Built with QML via Quickshell (visual OSD for volume/brightness/mic, interactive power menu, resource monitors, visualizer, and calendar).
- **Keyboard-Driven Workflow**: Ergonomic shortcuts for window management, workspace navigation, Wi-Fi/Bluetooth menus, and screenshot capture.

---

## 🛠 System Components

| Component | Software / Tool | Role / Purpose |
| :--- | :--- | :--- |
| **Compositor** | [Hyprland](https://hypr.land/) | Smooth, animated dynamic tiling Wayland compositor |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated terminal emulator |
| **Shell** | [Zsh](https://www.zsh.org/) + Oh-My-Zsh | Interactive shell with the official `nyverune` prompt theme |
| **Bar & Widgets** | [Quickshell](https://quickshell.outfoxxed.me/) | Native QML status bar, system monitors, OSD, and PowerMenu |
| **Launcher / Menus**| [Rofi (Wayland)](https://github.com/lbonn/rofi) | App launcher, clipboard history, Wi-Fi, and Bluetooth dialogs |
| **Notifications** | [Mako](https://github.com/emersion/mako) | Lightweight, customizable Wayland notification daemon |
| **Editor** | [Neovim](https://neovim.io/) | Text editor configured with Lazy.nvim, LSP, and Treesitter |
| **Wallpapers** | [Hyprpaper](https://github.com/hyprwm/hyprpaper) | Fast wallpaper daemon with persistent state restoration |
| **Screen Lock** | [Hyprlock](https://github.com/hyprwm/hyprlock) | Secure, hardware-accelerated Wayland screen locker |
| **Clipboard** | `cliphist` + `wl-clipboard` | Persistent clipboard history with interactive Rofi picker |
| **Audio Server** | PipeWire + WirePlumber (`wpctl`) | Audio routing, volume management, and visual OSD |
| **Audio Visualizer**| [Cava](https://github.com/karlstav/cava) | Terminal-based audio visualizer |
| **System Info** | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) | Modern system fetch tool with custom ASCII branding |
| **Browser** | [Zen Browser](https://zen-browser.app/) | Privacy-focused modern browser with custom `userChrome.css` |
| **Music** | Spotify + [Spicetify](https://spicetify.app/) | Spotify desktop client styled with the Nyverune theme |

---

## 📂 Repository Structure

This repository follows the standard **GNU Stow** directory layout, where each top-level directory mirrors the target path relative to `$HOME`:

```text
dotfiles/
├── bin/                          # Executable scripts (symlinked to ~/.local/bin/)
│   ├── hyprpaper-start           # Restores last wallpaper on login
│   ├── nyverune-theme            # Pywal-driven brand & image theming engine
│   ├── osd                       # OSD trigger for audio, mic, and brightness
│   └── powermenu                 # IPC trigger for Quickshell PowerMenu
├── cava/                         # Audio visualizer config (~/.config/cava)
├── fastfetch/                    # System fetch config (~/.config/fastfetch)
├── hypr/                         # Hyprland, hyprlock, and hyprpaper configs
├── kitty/                        # Kitty terminal emulator config (~/.config/kitty)
├── mako/                         # Mako notification daemon config (~/.config/mako)
├── nvim/                         # Neovim IDE configuration (~/.config/nvim)
├── quickshell/                   # QML status bar, widgets & OSD (~/.config/quickshell)
├── rofi/                         # Rofi launcher themes and menus (~/.config/rofi)
├── spicetify/                    # Nyverune theme for Spicetify
├── startpage/                    # Customizable web browser startpage
├── themes/                       # Master Pywal color palettes
├── zen/                          # Custom styles for Zen Browser (userChrome.css)
├── zsh/                          # .zshrc, .zshenv and modular ~/.config/zshrc/
├── packages-required.txt         # Required core packages & dependencies
├── packages-optional.txt         # Optional & recommended packages
├── setup.sh                      # Automated installer & verification script
└── install.sh                    # Symlink alias to setup.sh
```

---

## 🚀 Installation & Automated Setup

The repository provides an interactive Bash setup script ([setup.sh](file:///home/nyverune/nyverune/dotfiles/setup.sh) / [install.sh](file:///home/nyverune/nyverune/dotfiles/install.sh)) that:
1. Verifies that **GNU Stow** is installed (or prompts to install it).
2. Reads [packages-required.txt](file:///home/nyverune/nyverune/dotfiles/packages-required.txt), checks which core tools are missing, and installs them using your package manager (`yay`, `paru`, or `pacman`).
3. Reads [packages-optional.txt](file:///home/nyverune/nyverune/dotfiles/packages-optional.txt) and suggests installing optional packages (allowing batch install, selective install, or skipping).
4. Deploys symlinks using `stow` for all modules, automatically backing up any conflicting files.
5. Links custom scripts in `bin/` to `~/.local/bin/` and sets executable permissions.

### 1. Clone the repository

```bash
git clone https://github.com/nyverune/dotfiles.git ~/nyverune/dotfiles
cd ~/nyverune/dotfiles
```

### 2. Run the installer

```bash
./setup.sh
# or simply:
./install.sh
```

### CLI Flags & Options

You can customize the installer execution with flags:

```bash
# Check package status only without modifying your system
./setup.sh --check

# Skip package checking and only deploy GNU Stow symlinks
./setup.sh --stow-only

# Check and install packages only without running GNU Stow
./setup.sh --no-stow

# Automatically accept all interactive prompts
./setup.sh --yes

# View available flags and help
./setup.sh --help
```

---

## 📦 Package Lists

Package lists use a readable, user-editable format:
```text
package_name[:binary_command] [# Optional description]
```

### [packages-required.txt](file:///home/nyverune/nyverune/dotfiles/packages-required.txt) (Core)
Essential tools required for the desktop, terminal, and scripts to function properly:
- `stow`, `git`
- `hyprland`, `hyprpaper`, `hyprlock`, `hyprshot`
- `kitty`, `zsh`, `fzf`, `fastfetch`
- `neovim`, `rofi-wayland`
- `mako`, `cava`, `wireplumber`, `playerctl`
- `wl-clipboard`, `cliphist`, `python-pywal`
- `brightnessctl`, `networkmanager`, `bluez-utils`, `dolphin`
- `polkit-kde-agent`, `gnome-keyring`, `ttf-jetbrains-mono-nerd`

### [packages-optional.txt](file:///home/nyverune/nyverune/dotfiles/packages-optional.txt) (Extras)
Recommended software to enrich your overall experience:
- `yay` (AUR helper)
- `spotify` & `spicetify-cli` (Music streaming & custom client theme)
- `gopass` (Modern, secure console password manager)
- `quickshell` (Reactive QML desktop widgets and bar)
- `zen-browser-bin` (Zen Browser with custom chrome styling)
- `eza`, `bat`, `btop`, `tty-clock` (Modern CLI productivity tools)

---

## ⌨️ Keybindings

The main modifier key is <kbd>SUPER</kbd> (Windows key):

### Applications & Menus
| Shortcut | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>Return</kbd> | Open Kitty terminal |
| <kbd>SUPER</kbd> + <kbd>Space</kbd> | Open Rofi application launcher |
| <kbd>SUPER</kbd> + <kbd>E</kbd> | Open Dolphin file manager |
| <kbd>SUPER</kbd> + <kbd>Esc</kbd> / <kbd>Backspace</kbd> | Toggle Quickshell PowerMenu |
| <kbd>SUPER</kbd> + <kbd>L</kbd> | Lock screen with Hyprlock |
| <kbd>SUPER</kbd> + <kbd>W</kbd> | Open wallpaper selector |
| <kbd>SUPER</kbd> + <kbd>V</kbd> | Open clipboard history (Rofi + Cliphist) |
| <kbd>SUPER</kbd> + <kbd>N</kbd> | Wi-Fi network manager (Rofi + nmcli) |
| <kbd>SUPER</kbd> + <kbd>B</kbd> | Bluetooth device manager (Rofi + bluetoothctl) |

### Window Management & Workspaces
| Shortcut | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>K</kbd> | Close active window |
| <kbd>SUPER</kbd> + <kbd>T</kbd> | Toggle floating window |
| <kbd>SUPER</kbd> + <kbd>F</kbd> | Toggle fullscreen |
| <kbd>SUPER</kbd> + <kbd>←</kbd> <kbd>↓</kbd> <kbd>↑</kbd> <kbd>→</kbd> | Move focus between windows |
| <kbd>SUPER</kbd> + <kbd>1</kbd> - <kbd>9</kbd>, <kbd>0</kbd> | Switch to workspace 1-10 |
| <kbd>SUPER</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> - <kbd>9</kbd>, <kbd>0</kbd> | Move window to workspace 1-10 |
| <kbd>SUPER</kbd> + <kbd>S</kbd> | Toggle special scratchpad workspace |
| <kbd>SUPER</kbd> + <kbd>Left Click</kbd> | Drag / move window |
| <kbd>SUPER</kbd> + <kbd>Right Click</kbd> | Resize window |

### Screenshots & Multimedia
| Shortcut | Action |
| :--- | :--- |
| <kbd>Print</kbd> | Capture full screen output |
| <kbd>SUPER</kbd> + <kbd>Print</kbd> | Capture active window |
| <kbd>Shift</kbd> + <kbd>Print</kbd> | Capture selected region |
| <kbd>XF86AudioRaiseVolume</kbd> / <kbd>LowerVolume</kbd> | Adjust volume up / down (with OSD) |
| <kbd>XF86AudioMute</kbd> / <kbd>MicMute</kbd> | Toggle volume mute / mic mute |
| <kbd>XF86MonBrightnessUp</kbd> / <kbd>Down</kbd> | Adjust screen brightness up / down |
| Media Keys | Control Spotify playback (`play-pause`, `next`, `previous`) |

---

## 🎨 Nyverune Theme Engine

The custom `nyverune-theme` script generates dynamic color palettes powered by Pywal:

```bash
# Generate theme from any wallpaper image
nyverune-theme --image /path/to/wallpaper.jpg

# Toggle between dark and light modes
nyverune-theme --toggle

# Force specific mode
nyverune-theme --mode dark
nyverune-theme --mode light
```

When triggered, it reloads colors live across:
- Hyprpaper wallpaper.
- Kitty terminal and Neovim without restarting sessions.
- Quickshell status bar and Rofi launcher menus.
- Mako notifications daemon.
- Spicetify Spotify client and Zen Browser chrome.

---

## ⚙️ Custom Utilities & Scripts

Located in `bin/` and symlinked to `~/.local/bin/`:
- **`hyprpaper-start`**: Automatically loads and restores the last active wallpaper on startup.
- **`osd`**: Unified controller for volume, mic, and brightness with smooth on-screen display.
- **`powermenu`**: IPC caller for the Quickshell shutdown, restart, and sleep menu.
- **`nyverune-theme`**: Core brand theming engine with Pywal integration.

---

<div align="center">

Crafted with 💜 by **Nyverune**

</div>
