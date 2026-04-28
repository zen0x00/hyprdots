#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Stowing bin → /usr/bin ..."
sudo stow --dir="$DOTFILES_DIR" --target=/usr --stow bin

echo "Stowing zsh → $HOME ..."
stow --dir="$DOTFILES_DIR" --target="$HOME" --stow zsh

CONFIG_PACKAGES=(fastfetch hypr kitty quickshell rofi swayosd swaync waybar)

for pkg in "${CONFIG_PACKAGES[@]}"; do
    echo "Stowing $pkg → ~/.config/$pkg ..."
    mkdir -p "$HOME/.config/$pkg"
    stow --dir="$DOTFILES_DIR" --target="$HOME/.config/$pkg" --stow "$pkg"
done

echo "Done."
