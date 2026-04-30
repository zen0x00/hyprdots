#!/usr/bin/env bash
set -euo pipefail

# ── zen0x bootstrap ────────────────────────────────────────────────────────────
# Full system setup: packages → dotfiles → stow → theme → shell
# Target: Arch / CachyOS

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/zen0x00/dotfiles.git}"
DEFAULT_THEME="gruvbox"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { printf "${CYAN}:: %s${NC}\n" "$*"; }
success() { printf "${GREEN}✓  %s${NC}\n" "$*"; }
warn()    { printf "${YELLOW}!  %s${NC}\n" "$*"; }
die()     { printf "${RED}✗  %s${NC}\n" "$*" >&2; exit 1; }
step()    { printf "\n${CYAN}━━ %s ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n" "$*"; }

# ── sanity checks ──────────────────────────────────────────────────────────────
[[ "$EUID" -eq 0 ]] && die "Don't run as root — needs sudo internally."
command -v pacman >/dev/null 2>&1 || die "pacman not found — Arch/CachyOS only."

# ── packages ───────────────────────────────────────────────────────────────────
PACMAN_PACKAGES=(
    # Core tools
    git stow python3 micro

    # Shell
    zsh fzf zoxide starship eza fastfetch

    # Wayland / WM
    hyprland uwsm hypridle hyprlock hyprpaper hyprpolkitagent

    # Status bar / notifications / OSD
    waybar swaync swayosd

    # Launcher & terminal
    rofi-wayland kitty

    # File manager
    nautilus

    # Clipboard
    wl-clipboard cliphist

    # Audio / brightness
    pipewire pipewire-alsa pipewire-pulse wireplumber
    brightnessctl

    # Fonts (icons needed by eza, waybar, fastfetch)
    ttf-nerd-fonts-symbols
    ttf-jetbrains-mono-nerd
    noto-fonts noto-fonts-emoji
)

AUR_PACKAGES=(
    zen-browser-bin
    awww-git
    ly
)

step "AUR helper"
if ! command -v yay >/dev/null 2>&1; then
    info "Installing yay..."
    tmp="$(mktemp -d)"
    git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    success "yay installed"
else
    success "yay already present"
fi

step "System packages (pacman)"
sudo pacman -Syu --needed --noconfirm "${PACMAN_PACKAGES[@]}"
success "pacman packages done"

step "AUR packages"
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
success "AUR packages done"

# ── dotfiles ───────────────────────────────────────────────────────────────────
step "Dotfiles"
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    success "Repo already at $DOTFILES_DIR"
else
    info "Cloning dotfiles → $DOTFILES_DIR"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    success "Cloned"
fi

# ── git identity ───────────────────────────────────────────────────────────────
step "Git identity"
current_name="$(git config --global --get user.name 2>/dev/null || true)"
current_email="$(git config --global --get user.email 2>/dev/null || true)"

if [[ -n "$current_name" && -n "$current_email" ]]; then
    warn "Git already configured as $current_name <$current_email>"
    printf "Reconfigure? [y/N] "; read -r reconfigure
    [[ "${reconfigure,,}" != "y" ]] && configure_git=false || configure_git=true
else
    configure_git=true
fi

if [[ "${configure_git:-true}" == "true" ]]; then
    printf "GitHub username: "; read -r github_username
    printf "GitHub email: "    ; read -r github_email
    [[ -z "$github_username" ]] && die "Username cannot be empty."
    [[ -z "$github_email"    ]] && die "Email cannot be empty."
    git config --global user.name  "$github_username"
    git config --global user.email "$github_email"
    success "Git configured: $github_username <$github_email>"
fi

# ── stow ───────────────────────────────────────────────────────────────────────
step "Stow configs"
cd "$DOTFILES_DIR"

info "bin → /usr/bin"
sudo stow --dir="$DOTFILES_DIR" --target=/usr --stow bin

info "zsh → $HOME"
stow --dir="$DOTFILES_DIR" --target="$HOME" --stow zsh

CONFIG_PACKAGES=(fastfetch hypr kitty rofi swayosd swaync waybar)
for pkg in "${CONFIG_PACKAGES[@]}"; do
    if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
        info "$pkg → ~/.config/$pkg"
        mkdir -p "$HOME/.config/$pkg"
        stow --dir="$DOTFILES_DIR" --target="$HOME/.config/$pkg" --stow "$pkg"
    fi
done

success "Stow done"

# ── theme ──────────────────────────────────────────────────────────────────────
step "Apply default theme ($DEFAULT_THEME)"
if command -v zen0x-apply-theme >/dev/null 2>&1; then
    zen0x-apply-theme "$DEFAULT_THEME" || warn "Theme apply failed — run 'zen0x-apply-theme $DEFAULT_THEME' manually"
    success "Theme applied: $DEFAULT_THEME"
else
    warn "zen0x-apply-theme not in PATH yet — run it after logging in."
fi

# ── default shell ──────────────────────────────────────────────────────────────
step "Default shell"
ZSH_BIN="$(command -v zsh)"
if [[ "$SHELL" == "$ZSH_BIN" ]]; then
    success "zsh already default shell"
else
    info "Setting zsh as default shell..."
    grep -qxF "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | sudo tee -a /etc/shells
    chsh -s "$ZSH_BIN"
    success "Default shell → zsh (takes effect next login)"
fi

# ── services ───────────────────────────────────────────────────────────────────
step "Services"

info "Disabling getty@tty2, enabling ly@tty2..."
sudo systemctl disable getty@tty2.service
sudo systemctl enable ly@tty2.service
success "ly display manager enabled on tty2"

info "Enabling hyprpolkitagent (user)..."
systemctl --user enable hyprpolkitagent
success "hyprpolkitagent enabled"

# ── uwsm / session ─────────────────────────────────────────────────────────────
step "Hyprland session"
info "uwsm manages Hyprland autostart. Select 'Hyprland' in your display manager."
info "Or from TTY: uwsm start hyprland.desktop"

# ── done ───────────────────────────────────────────────────────────────────────
printf "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${GREEN}  Done. Log out and back in (or reboot) to start.${NC}\n"
printf "${GREEN}  Switch themes: zen0x-theme-menu${NC}\n"
printf "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n\n"
