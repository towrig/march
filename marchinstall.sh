#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

require_root

info "Running marchinstall..."

# ---- Core tools every module can rely on ----
info "Installing core system tools..."
pacman -S --needed --noconfirm \
  git \
  curl \
  base-devel

# ---- Install modules ----
info "Installing modules..."
"$SCRIPT_DIR/modules/cachyos-kernel.sh"
"$SCRIPT_DIR/modules/hyprland.sh"
"$SCRIPT_DIR/modules/sddm.sh"

info "marchinstall completed successfully."
warn "Reboot recommended."