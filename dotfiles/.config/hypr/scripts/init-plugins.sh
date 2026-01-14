#!/usr/bin/env bash
# Initialize Hyprland plugins on startup using hyprpm
# This script runs once per session to ensure plugins are loaded

PLUGIN_MARKER="$HOME/.cache/hypr-plugins-initialized"
HYPRLAND_PLUGINS_REPO="https://github.com/hyprwm/hyprland-plugins"

# Check if we already initialized plugins this session
if [[ -f "$PLUGIN_MARKER" ]]; then
    exit 0
fi

# Wait for Hyprland to be fully ready
sleep 2

# Check if hyprpm has the official plugins repo
if ! hyprpm list 2>/dev/null | grep -q "hyprbars"; then
    # Add the official hyprland-plugins repository
    hyprpm add "$HYPRLAND_PLUGINS_REPO" -q 2>/dev/null || true
fi

# Enable hyprbars if available
hyprpm enable hyprbars -q 2>/dev/null || true

# Reload to apply plugins
hyprpm reload -q 2>/dev/null || true

# Mark as initialized for this session
mkdir -p "$(dirname "$PLUGIN_MARKER")"
touch "$PLUGIN_MARKER"

