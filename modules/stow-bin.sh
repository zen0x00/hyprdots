#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BIN_TARGET="${BIN_TARGET:-/usr/bin}"

command -v stow >/dev/null 2>&1 || {
  echo "stow is required." >&2
  exit 1
}

sudo mkdir -p "$BIN_TARGET"
sudo stow --dir="$DOTFILES_DIR" --target="$BIN_TARGET" --restow bin
