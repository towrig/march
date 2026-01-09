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
  pipewire-bluetooth \
  blueman

# Status bar and launcher
pacman -S --needed --noconfirm waybar rofi

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

# Install hyprbars plugin via hyprpm (run as actual user, not root)
info "Installing hyprbars plugin..."
su - "$(get_real_user)" -c "hyprpm update && hyprpm add https://github.com/hyprwm/hyprland-plugins && hyprpm enable hyprbars" || warn "hyprbars plugin installation failed - you may need to install it manually"

# Deploy dotfiles
DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"
if [[ -d "$DOTFILES_DIR" ]]; then
  deploy_dotfiles "$DOTFILES_DIR"
else
  warn "Dotfiles directory not found at $DOTFILES_DIR - skipping dotfiles deployment."
fi

info "Hyprland installation complete."
