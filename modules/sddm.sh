#!/usr/bin/env bash
set -euo pipefail

# ---- COMMON HELPERS ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

require_root

info "Installing and configuring display manager (SDDM) with SilentSDDM for Hyprland..."

# ---- 1️⃣ Install SDDM and dependencies ----
info "Installing SDDM and required Qt packages..."
pacman -S --needed --noconfirm sddm qt6-svg qt6-virtualkeyboard qt6-multimedia git

# ---- 2️⃣ Clone SilentSDDM if not already present ----
THEME_DIR="/usr/share/sddm/themes/SilentSDDM"
if [[ ! -d "$THEME_DIR" ]]; then
    info "Cloning SilentSDDM theme..."
    git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM.git /tmp/SilentSDDM
    info "Installing SilentSDDM theme..."
    cp -r /tmp/SilentSDDM "$THEME_DIR"
    rm -rf /tmp/SilentSDDM
else
    info "SilentSDDM already installed."
fi

# ---- 3️⃣ Create Hyprland Wayland session ----
SESSION_FILE="/usr/share/wayland-sessions/hyprland.desktop"

if [[ ! -f "$SESSION_FILE" ]]; then
    info "Creating Hyprland Wayland session file..."
    cat > "$SESSION_FILE" <<EOF
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland Session
Exec=Hyprland
Type=Application
EOF
else
    info "Hyprland session file already exists."
fi

# ---- 4️⃣ Configure SDDM to use SilentSDDM ----
SDDM_CONF="/etc/sddm.conf"
mkdir -p "$(dirname "$SDDM_CONF")"

if ! grep -q "^\[Theme\]" "$SDDM_CONF" 2>/dev/null; then
    echo "[Theme]" >> "$SDDM_CONF"
fi

if grep -q "^Current=" "$SDDM_CONF"; then
    sed -i "s/^Current=.*/Current=SilentSDDM/" "$SDDM_CONF"
else
    echo "Current=SilentSDDM" >> "$SDDM_CONF"
fi

info "SDDM theme set to SilentSDDM."

# ---- 5️⃣ Enable SDDM service ----
if ! systemctl is-enabled sddm >/dev/null 2>&1; then
    info "Enabling SDDM service..."
    systemctl enable sddm
else
    info "SDDM service already enabled."
fi

# ---- 6️⃣ Optional: configure auto-login ----
read -rp "Do you want to enable auto-login for the current user? [y/N]: " AUTOLOGIN

if [[ "${AUTOLOGIN,,}" == "y" ]]; then
    info "Setting up auto-login for user: $SUDO_USER"

    if ! grep -q "^\[Autologin\]" "$SDDM_CONF" 2>/dev/null; then
        echo "[Autologin]" >> "$SDDM_CONF"
    fi

    # Replace or add User line
    if grep -q "^User=" "$SDDM_CONF"; then
        sed -i "s/^User=.*/User=$SUDO_USER/" "$SDDM_CONF"
    else
        echo "User=$SUDO_USER" >> "$SDDM_CONF"
    fi

    # Replace or add Session line
    if grep -q "^Session=" "$SDDM_CONF"; then
        sed -i "s/^Session=.*/Session=Hyprland/" "$SDDM_CONF"
    else
        echo "Session=Hyprland" >> "$SDDM_CONF"
    fi

    info "Auto-login enabled for user: $SUDO_USER"
else
    info "Auto-login not enabled."
fi

info "Display manager setup complete. Reboot to test SilentSDDM + Hyprland login."