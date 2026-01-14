#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

require_root
info "Installing Hyprland and dependencies..."

# Core Hyprland packages
pacman -S --needed --noconfirm \
  hyprland \
  wayland \
  wayland-protocols \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal \
  wl-clipboard

# Terminal and shell
pacman -S --needed --noconfirm alacritty 

# Audio (PipeWire stack)
pacman -S --needed --noconfirm \
  pipewire \
  wireplumber \
  pipewire-audio \
  pipewire-pulse

# Bluetooth
pacman -S --needed --noconfirm \
  bluez \
  bluez-utils \
  blueman

# Status bar and launcher
pacman -S --needed --noconfirm waybar rofi

# File manager (Nemo with extensions)
pacman -S --needed --noconfirm \
  nemo \
  nemo-fileroller \
  file-roller

# Wallpaper
pacman -S --needed --noconfirm swww

# Utilities
pacman -S --needed --noconfirm brightnessctl playerctl swaync

# Fonts
pacman -S --needed --noconfirm \
  ttf-jetbrains-mono-nerd \
  ttf-font-awesome \
  noto-fonts \
  noto-fonts-emoji

info "Hyprland packages installed."

# Enable Bluetooth service
info "Enabling Bluetooth service..."
systemctl enable bluetooth

# Deploy dotfiles
DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"
REAL_USER="$(get_real_user)"
REAL_HOME="$(eval echo "~$REAL_USER")"

if [[ -d "$DOTFILES_DIR" ]]; then
  deploy_dotfiles "$DOTFILES_DIR"
  
  # Make Hyprland scripts executable
  chmod +x "$REAL_HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true
else
  warn "Dotfiles directory not found at $DOTFILES_DIR - skipping dotfiles deployment."
fi

info "Hyprland installation complete."
info "Note: hyprbars plugin will be installed automatically on first login via hyprpm."
