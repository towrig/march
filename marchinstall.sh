#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

require_root

info "Running marchinstall..."

# ---- Core tools every module can rely on ----
info "Installing core tools..."
pacman -S --needed --noconfirm \
  git \
  curl \
  base-devel \
  meson \
  cpio \
  cmake \
  nano

# ---- Install yay (AUR helper) ----
REAL_USER="$(get_real_user)"
REAL_HOME="$(get_real_home)"
YAY_BUILD_DIR="$REAL_HOME/.cache/yay-install"

if command -v yay &>/dev/null; then
  info "yay is already installed."
else
  info "Installing yay AUR helper..."
  
  # Create build directory
  su - "$REAL_USER" -c "mkdir -p '$YAY_BUILD_DIR'"
  
  # Clone and build yay-bin (precompiled, faster)
  su - "$REAL_USER" -c "
    cd '$YAY_BUILD_DIR' && \
    git clone https://aur.archlinux.org/yay-bin.git && \
    cd yay-bin && \
    makepkg -s --noconfirm
  "
  
  # Install the built package as root
  pacman -U --noconfirm "$YAY_BUILD_DIR"/yay-bin/yay-bin-*.pkg.tar.zst
  
  # Clean up build files
  info "Cleaning up yay build files..."
  rm -rf "$YAY_BUILD_DIR"
  
  info "yay installed successfully."
fi

# ---- Install modules ----
info "Installing modules..."
"$SCRIPT_DIR/modules/cachyos-kernel.sh"
"$SCRIPT_DIR/modules/hyprland.sh"
"$SCRIPT_DIR/modules/sddm.sh"

info "marchinstall completed successfully."
warn "Reboot recommended."