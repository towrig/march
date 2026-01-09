#!/usr/bin/env bash
set -euo pipefail

# ---- COMMON HELPERS ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

require_root

info "Installing and configuring display manager (SDDM) with SilentSDDM for Hyprland..."


# ---- 2️⃣ Clone and install SilentSDDM using official install script ----
# The install.sh handles: dependencies, file copying, fonts, and sddm.conf configuration
THEME_DIR="/usr/share/sddm/themes/silent"
if [[ ! -d "$THEME_DIR" ]]; then
    info "Cloning SilentSDDM theme..."
    git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM.git /tmp/SilentSDDM
    info "Running SilentSDDM install script..."
    cd /tmp/SilentSDDM
    chmod +x install.sh
    ./install.sh
    cd -
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

# ---- 4️⃣ Enable SDDM service ----
if ! systemctl is-enabled sddm >/dev/null 2>&1; then
    info "Enabling SDDM service..."
    systemctl enable sddm
else
    info "SDDM service already enabled."
fi

# ---- 5️⃣ Optional: configure auto-login ----
read -rp "Do you want to enable auto-login for the current user? [y/N]: " AUTOLOGIN

if [[ "${AUTOLOGIN,,}" == "y" ]]; then
    info "Setting up auto-login for user: $SUDO_USER"
    cat >> /etc/sddm.conf <<EOF

[Autologin]
User=$SUDO_USER
Session=Hyprland
EOF
    info "Auto-login enabled for user: $SUDO_USER"
else
    info "Auto-login not enabled."
fi

info "Display manager setup complete. Reboot to test SilentSDDM + Hyprland login."