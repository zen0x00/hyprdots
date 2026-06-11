#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
STOW_BACKUP_ROOT="${STOW_BACKUP_ROOT:-$HOME/.local/state/zen0x-stow-backups}"
STOW_TIMESTAMP="${STOW_TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"
STOW_BACKUP_DIR="$STOW_BACKUP_ROOT/$STOW_TIMESTAMP"
BIN_TARGET="${BIN_TARGET:-/usr}"
HOME_TARGET="${HOME_TARGET:-$HOME}"
CONFIG_ROOT_TARGET="${CONFIG_ROOT_TARGET:-$HOME/.config}"
BACKUP_USED=false

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { printf "${CYAN}:: %s${NC}\n" "$*"; }
success() { printf "${GREEN}✓  %s${NC}\n" "$*"; }
warn()    { printf "${YELLOW}!  %s${NC}\n" "$*"; }
die()     { printf "${RED}✗  %s${NC}\n" "$*" >&2; exit 1; }

command -v stow >/dev/null 2>&1 || die "stow is required."
command -v realpath >/dev/null 2>&1 || die "realpath is required."

ensure_backup_dir() {
    if [[ "$BACKUP_USED" == false ]]; then
        mkdir -p "$STOW_BACKUP_DIR"
        BACKUP_USED=true
    fi
}

path_exists() {
    local use_sudo="$1"
    local path="$2"

    if [[ "$use_sudo" == true ]]; then
        sudo test -e "$path" || sudo test -L "$path"
    else
        [[ -e "$path" || -L "$path" ]]
    fi
}

path_is_dir() {
    local use_sudo="$1"
    local path="$2"

    if [[ "$use_sudo" == true ]]; then
        sudo test -d "$path"
    else
        [[ -d "$path" ]]
    fi
}

path_is_symlink() {
    local use_sudo="$1"
    local path="$2"

    if [[ "$use_sudo" == true ]]; then
        sudo test -L "$path"
    else
        [[ -L "$path" ]]
    fi
}

read_symlink() {
    local use_sudo="$1"
    local path="$2"

    if [[ "$use_sudo" == true ]]; then
        sudo readlink "$path"
    else
        readlink "$path"
    fi
}

backup_path() {
    local use_sudo="$1"
    local path="$2"
    local rel="${path#/}"
    local backup_path="$STOW_BACKUP_DIR/$rel"

    ensure_backup_dir
    mkdir -p "$(dirname "$backup_path")"

    if [[ "$use_sudo" == true ]]; then
        sudo mkdir -p "$(dirname "$backup_path")"
        sudo mv "$path" "$backup_path"
    else
        mv "$path" "$backup_path"
    fi

    warn "Moved existing path to backup: $path"
}

prepare_conflicts() {
    local package="$1"
    local target_root="$2"
    local use_sudo="$3"
    local package_root="$DOTFILES_DIR/$package"

    while IFS= read -r -d '' source_path; do
        local rel_path="${source_path#$package_root/}"
        local target_path="$target_root/$rel_path"

        if [[ -d "$source_path" && ! -L "$source_path" ]]; then
            if path_exists "$use_sudo" "$target_path" && ! path_is_dir "$use_sudo" "$target_path"; then
                backup_path "$use_sudo" "$target_path"
            fi
            continue
        fi

        if ! path_exists "$use_sudo" "$target_path"; then
            continue
        fi

        local resolved_existing expected_target
        resolved_existing="$(realpath -m "$target_path")"
        expected_target="$(realpath -m "$source_path")"

        if [[ "$resolved_existing" == "$expected_target" ]]; then
            continue
        fi

        if path_is_symlink "$use_sudo" "$target_path"; then
            local link_target resolved_target
            link_target="$(read_symlink "$use_sudo" "$target_path")"
            resolved_target="$(realpath -m "$(dirname "$target_path")/$link_target")"

            if [[ "$resolved_target" == "$expected_target" ]]; then
                continue
            fi
        fi

        backup_path "$use_sudo" "$target_path"
    done < <(find "$package_root" -mindepth 1 -print0)
}

stow_package() {
    local package="$1"
    local target_root="$2"
    local use_sudo="$3"
    local package_root="$DOTFILES_DIR/$package"
    local -a stow_cmd=(stow --dir="$DOTFILES_DIR" --target="$target_root" --restow "$package")
    local -a simulate_cmd=(stow --simulate --dir="$DOTFILES_DIR" --target="$target_root" --restow "$package")

    [[ -d "$package_root" ]] || { warn "Skipping missing package: $package"; return 0; }

    if [[ "$use_sudo" == true ]]; then
        info "$package → $target_root (sudo)"
        sudo mkdir -p "$target_root"
    else
        info "$package → $target_root"
        mkdir -p "$target_root"
    fi

    prepare_conflicts "$package" "$target_root" "$use_sudo"

    if [[ "$use_sudo" == true ]]; then
        sudo "${simulate_cmd[@]}" >/dev/null
        sudo "${stow_cmd[@]}"
    else
        "${simulate_cmd[@]}" >/dev/null
        "${stow_cmd[@]}"
    fi

    success "Stowed $package"
}

BIN_USE_SUDO="${BIN_USE_SUDO:-true}"

stow_package "bin" "$BIN_TARGET" "$BIN_USE_SUDO"
stow_package "zsh" "$HOME_TARGET" false

CONFIG_PACKAGES=(fastfetch hypr kitty rofi swayosd swaync waybar)
for pkg in "${CONFIG_PACKAGES[@]}"; do
    stow_package "$pkg" "$CONFIG_ROOT_TARGET/$pkg" false
done

if [[ "$BACKUP_USED" == true ]]; then
    success "Backups saved to $STOW_BACKUP_DIR"
fi

success "Stow complete"
