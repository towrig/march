#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"

require_root
info "Installing CachyOS kernel..."

# ---- CONFIG ----
CACHYOS_REPO_NAME="cachyos"
CACHYOS_MIRRORLIST="/etc/pacman.d/cachyos-mirrorlist"
PACMAN_CONF="/etc/pacman.conf"

# ---- CHECK ARCH ----
if ! command -v pacman >/dev/null; then
  error "pacman not found. This script is for Arch Linux only."
fi

info "Starting CachyOS kernel installation..."

# ---- IMPORT CACHYOS GPG KEYS ----
info "Importing CachyOS signing keys..."
pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key F3B607488DB35A47

# ---- ADD MIRRORLIST ----
if [[ ! -f "$CACHYOS_MIRRORLIST" ]]; then
  info "Creating CachyOS mirrorlist..."
  cat > "$CACHYOS_MIRRORLIST" <<EOF
Server = https://mirror.cachyos.org/repo/\$arch/\$repo
EOF
else
  info "CachyOS mirrorlist already exists."
fi

# ---- ADD REPO TO PACMAN ----
if ! grep -q "^\[$CACHYOS_REPO_NAME\]" "$PACMAN_CONF"; then
  info "Adding CachyOS repo to pacman.conf..."
  # Add repo after [options] section, before other repos
  sed -i "/^\[core\]/i [$CACHYOS_REPO_NAME]\nSigLevel = Optional TrustAll\nInclude = $CACHYOS_MIRRORLIST\n" "$PACMAN_CONF"
else
  info "CachyOS repo already present in pacman.conf."
fi

# ---- SYNC DATABASES ----
info "Syncing package databases..."
pacman -Sy --noconfirm

# ---- INSTALL KERNEL ----
info "Installing CachyOS kernel..."
pacman -S --needed --noconfirm linux-cachyos linux-cachyos-headers

# ---- DONE ----
info "CachyOS kernel installed successfully."

echo
info "Reboot your system and select the CachyOS kernel."
info "Verify after reboot with: uname -r"
warn "Do NOT remove your existing kernel until you've confirmed everything works."