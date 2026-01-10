# marchinstall

A simple script to set up a minimal Arch installation with Hyprland (floating windows), lovingly called "march".
Also swaps the kernel for CachyOS binaries for better gaming performance.

## Usage

```bash
sudo ./marchinstall.sh
```

## Packages

- **hyprland** - Hyprland, duh
- **yay** - AUR helper
- **sddm** - Display Manager
  - using the SilentSDDM theme

### Terminal

- **alacritty** - GPU-accelerated terminal

### Audio

- **pipewire** - Modern audio server. `pipewire-audio` and `pipewire-pulse` are also included.
- **wireplumber** - PipeWire session manager
- **blueman** - Bluetooth manager. `bluez` packages are also installed so pipewire can handle bluetooth.

### Desktop

- **waybar** - Status bar
- **rofi** - Application launcher
- **swaync** - Notification daemon
- **swww** - Animated wallpaper daemon

### Utilities

- **brightnessctl** - Brightness control
- **playerctl** - Media player control

### Fonts

- **ttf-jetbrains-mono-nerd** - Terminal/coding font with icons
- **ttf-font-awesome** - Icon font
- **noto-fonts**, **noto-fonts-emoji** - Unicode coverage

### Hyprland plugins

- **hyprbars** - Window title bars (installed via hyprpm)

## Dotfiles

Running `marchinstall` as the logged in user will deploy them automatically.
However, if you wish to manually use the configs, place the contents of `dotfiles/.config/` in `~/.config/` of your user.

```js
dotfiles/
  .config/
    hypr/
      hyprland.conf
      wallpaper.png
    alacritty/
      alacritty.toml
    waybar/
      config
      style.css
```

## Keybindings

| Key | Action |
| --- | ------ |
| `Super + Return` | Terminal (Alacritty) |
| `Super + D` | App launcher (Rofi) |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Print` | Screenshot selection |
