#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

require_root
info "Installing zsh with oh-my-zsh..."

# Install zsh and fastfetch
pacman -S --needed --noconfirm zsh fastfetch

REAL_USER="$(get_real_user)"
REAL_HOME="$(get_real_home)"
OMZ_DIR="$REAL_HOME/.oh-my-zsh"

# Install oh-my-zsh (unattended, as the real user)
if [[ -d "$OMZ_DIR" ]]; then
  info "oh-my-zsh is already installed."
else
  info "Installing oh-my-zsh..."
  # Clone oh-my-zsh directly (bypasses the interactive installer)
  su - "$REAL_USER" -c "git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git '$OMZ_DIR'"
  info "oh-my-zsh installed."
fi

# Deploy .zshrc from dotfiles (if present)
DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"
ZSHRC_SRC="$DOTFILES_DIR/.zshrc"

if [[ -f "$ZSHRC_SRC" ]]; then
  info "Deploying .zshrc..."
  cp "$ZSHRC_SRC" "$REAL_HOME/.zshrc"
  chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.zshrc"
else
  # If no custom .zshrc, copy the oh-my-zsh template
  if [[ ! -f "$REAL_HOME/.zshrc" ]]; then
    info "No custom .zshrc found, using oh-my-zsh template..."
    cp "$OMZ_DIR/templates/zshrc.zsh-template" "$REAL_HOME/.zshrc"
    chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.zshrc"
  fi
fi

# Change user's default shell to zsh
CURRENT_SHELL="$(getent passwd "$REAL_USER" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" == "/usr/bin/zsh" ]]; then
  info "zsh is already the default shell for $REAL_USER."
else
  info "Setting zsh as default shell for $REAL_USER..."
  chsh -s /usr/bin/zsh "$REAL_USER"
  info "Default shell changed to zsh."
fi

info "zsh + oh-my-zsh installation complete."

