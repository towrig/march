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

# ---- CONFIGURE BOOTLOADER ----
CACHYOS_BOOT_ENTRY="/boot/loader/entries/linux-cachyos.conf"

if [[ -d /boot/loader/entries ]]; then
  info "systemd-boot detected, configuring boot entry..."
  
  if [[ -f "$CACHYOS_BOOT_ENTRY" ]]; then
    info "CachyOS boot entry already exists."
  else
    # Find existing entry to extract kernel options
    EXISTING_ENTRY=$(find /boot/loader/entries -name "*.conf" -type f | head -n1)
    
    if [[ -n "$EXISTING_ENTRY" && -f "$EXISTING_ENTRY" ]]; then
      # Extract options line from existing entry
      KERNEL_OPTIONS=$(grep "^options" "$EXISTING_ENTRY" | head -n1 | sed 's/^options\s*//')
      
      info "Creating CachyOS boot entry..."
      cat > "$CACHYOS_BOOT_ENTRY" <<EOF
title   Arch Linux (CachyOS)
linux   /vmlinuz-linux-cachyos
initrd  /initramfs-linux-cachyos.img
options $KERNEL_OPTIONS
EOF
      info "Boot entry created at $CACHYOS_BOOT_ENTRY"
    else
      warn "No existing boot entry found to copy options from."
      warn "You may need to manually create: $CACHYOS_BOOT_ENTRY"
    fi
  fi
  
  # Update bootloader
  bootctl update 2>/dev/null || true
  
elif [[ -f /boot/grub/grub.cfg ]]; then
  info "GRUB detected, regenerating config..."
  grub-mkconfig -o /boot/grub/grub.cfg
else
  warn "Unknown bootloader. You may need to manually configure it."
fi

# ---- DONE ----
info "CachyOS kernel installed successfully."

echo
info "Reboot your system and select the CachyOS kernel."
info "Verify after reboot with: uname -r"
warn "Do NOT remove your existing kernel until you've confirmed everything works."