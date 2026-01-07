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