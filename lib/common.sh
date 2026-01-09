#!/usr/bin/env bash
set -euo pipefail

info() {
  echo -e "\e[1;34m[INFO]\e[0m $1"
}

warn() {
  echo -e "\e[1;33m[WARN]\e[0m $1"
}

error() {
  echo -e "\e[1;31m[ERROR]\e[0m $1"
  exit 1
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (use sudo)."
  fi
}

# Get the actual user (not root when using sudo)
get_real_user() {
  echo "${SUDO_USER:-$USER}"
}

get_real_home() {
  local real_user
  real_user="$(get_real_user)"
  eval echo "~$real_user"
}

# Deploy dotfiles from source directory to user's home
# Usage: deploy_dotfiles /path/to/dotfiles
deploy_dotfiles() {
  local src_dir="$1"
  local real_user real_home

  real_user="$(get_real_user)"
  real_home="$(get_real_home)"

  if [[ ! -d "$src_dir" ]]; then
    warn "Dotfiles directory not found: $src_dir"
    return 1
  fi

  info "Deploying dotfiles to $real_home..."

  # Find all files in the dotfiles directory and copy them
  while IFS= read -r -d '' file; do
    # Get relative path from dotfiles dir
    local rel_path="${file#$src_dir/}"
    local dest="$real_home/$rel_path"
    local dest_dir
    dest_dir="$(dirname "$dest")"

    # Create destination directory if needed
    if [[ ! -d "$dest_dir" ]]; then
      mkdir -p "$dest_dir"
      chown "$real_user:$real_user" "$dest_dir"
    fi

    # Copy file and set ownership
    cp "$file" "$dest"
    chown "$real_user:$real_user" "$dest"
    info "  Deployed: $rel_path"
  done < <(find "$src_dir" -type f -print0)

  info "Dotfiles deployment complete."
}