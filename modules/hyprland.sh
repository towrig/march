#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"

require_root
info "Installing Hyprland..."

pacman -S --needed --noconfirm \
  hyprland \
  wayland \
  wayland-protocols \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal \
  wl-clipboard \
  alacritty \
  pipewire \
  wireplumber

info "Hyprland installed."