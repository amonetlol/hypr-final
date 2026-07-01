#!/usr/bin/env bash
# Helpers partilhados — final_release

set -euo pipefail

INSTALL_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS_DIR="$(cd "$INSTALL_LIB_DIR/.." && pwd)"
# shellcheck source=sudo.sh
[[ -f "$INSTALL_LIB_DIR/sudo.sh" ]] && source "$INSTALL_LIB_DIR/sudo.sh"

log() { printf "\n[*] %s\n" "$1"; }
ok() { printf "[OK] %s\n" "$1"; }
warn() { printf "[AVISO] %s\n" "$1"; }
die() { printf "[ERRO] %s\n" "$1" >&2; exit 1; }

detect_repo_root() {
  local dir="${1:-$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/shared-themes/packs" && -d "$dir/installers" ]]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  die "Raiz do repo não encontrada (esperado shared-themes/packs + installers/)"
}

REPO_ROOT="${REPO_ROOT:-$(detect_repo_root)}"
THEMES_SRC="$REPO_ROOT/shared-themes"
THEMES_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/themes"
HYPR_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
INSTALL_DIR="$REPO_ROOT/installers"
DOTFILES_DIR="$REPO_ROOT/dotfiles"
DOTFILES_ALT="$REPO_ROOT/dotfiles-alt"

# shellcheck source=hypr-format.sh
source "$INSTALL_LIB_DIR/hypr-format.sh"

run() {
  log "$*"
  "$@"
}

need_sudo() {
  if ! sudo -n true 2>/dev/null; then
    warn "Será pedida senha sudo."
  fi
}

copy_themes() {
  log "Copiando theme engine para $THEMES_DEST"
  mkdir -p "$(dirname "$THEMES_DEST")"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete \
      --exclude '.git' \
      --exclude 'matugen/generated' \
      "$THEMES_SRC/" "$THEMES_DEST/"
  else
    rm -rf "${THEMES_DEST:?}"/*
    cp -a "$THEMES_SRC/." "$THEMES_DEST/"
  fi
  ok "Theme engine em $THEMES_DEST"
}

deploy_hypr_configs() {
  local hypr_dir="${1:-$HYPR_DEST}"
  deploy_hypr_configs_to_dir "$hypr_dir"
}

link_hypr_theme_files() {
  local hypr_dir="${1:-$HYPR_DEST}"
  local cfg="$HOME/.config"
  mkdir -p "$hypr_dir" "$cfg"
  ln -sfn "$THEMES_DEST/hypr/theme.conf" "$hypr_dir/theme.conf"
  ln -sfn "$THEMES_DEST/hypr/theme.lua" "$hypr_dir/theme.lua"
  ln -sfn "$THEMES_DEST/wlogout" "$cfg/wlogout"
  ln -sfn "$THEMES_DEST/starship/starship.toml" "$cfg/starship.toml"
}

setup_hyprlock_wallpaper() {
  local wall_dir="$HOME/Imagens/wallpapers"
  local target="$wall_dir/hyprlock.jpg"
  mkdir -p "$wall_dir"
  if [[ ! -f "$target" ]]; then
    local candidate
    candidate="$(find "$wall_dir" -type f \( -iname '*.jpg' -o -iname '*.png' \) 2>/dev/null | head -1)"
    if [[ -n "$candidate" ]]; then
      ln -sfn "$candidate" "$target"
      ok "hyprlock.jpg -> $candidate"
    else
      warn "Sem wallpapers em $wall_dir — adicione hyprlock.jpg manualmente"
    fi
  fi
}

deploy_dotfiles() {
  local src="$DOTFILES_DIR"
  [[ -d "$src/bash" ]] || die "dotfiles/bash ausente"

  log "Dotfiles shell"
  cp -f "$src/bash/.bashrc" "$HOME/.bashrc"
  cp -f "$src/bash/.bash_profile" "$HOME/.bash_profile"
  cp -f "$src/bash/.aliases" "$HOME/.aliases" 2>/dev/null || warn ".aliases ausente"
  cp -f "$src/bash/.aliases-arch" "$HOME/.aliases-arch"
  cp -f "$src/bash/.functions" "$HOME/.functions" 2>/dev/null || warn ".functions ausente"

  if [[ -d "$src/bin" ]] && [[ -n "$(ls -A "$src/bin" 2>/dev/null)" ]]; then
    mkdir -p "$HOME/.bin"
    cp -a "$src/bin/." "$HOME/.bin/"
    chmod +x "$HOME/.bin/"*
    ok "~/.bin ($(find "$HOME/.bin" -maxdepth 1 -type f | wc -l) scripts)"
  fi

  if [[ -d "$src/fastfetch/fastfetch" ]]; then
    mkdir -p "$HOME/.config/fastfetch"
    cp -a "$src/fastfetch/fastfetch/." "$HOME/.config/fastfetch/"
    ok "fastfetch configs"
  fi

  if [[ -d "$src/fonts" ]]; then
    mkdir -p "$HOME/.fonts"
    cp -a "$src/fonts/." "$HOME/.fonts/"
    fc-cache -f "$HOME/.fonts" 2>/dev/null || true
    ok "fonts em ~/.fonts"
  fi
}

clone_wallpapers() {
  local dest="$HOME/Imagens/wallpapers"
  mkdir -p "$dest"

  if [[ -d "$dest/.git" ]]; then
    ok "wall2 já clonado"
    setup_hyprlock_wallpaper
    return 0
  fi

  local repo="${WALLS_REPO_URL:-https://github.com/amonetlol/wall2.git}"
  if command -v git >/dev/null 2>&1; then
    log "Clonando wallpapers ($repo)"
    if GIT_TERMINAL_PROMPT=0 git clone --depth=1 "$repo" "$dest" 2>/dev/null; then
      ok "wall2 em $dest"
      setup_hyprlock_wallpaper
      return 0
    fi
  fi

  warn "wall2 indisponível — copie wallpapers para $dest"
}

enable_services() {
  log "Serviços"
  if systemctl list-unit-files sshd.service &>/dev/null; then
    sudo systemctl enable --now sshd 2>/dev/null || warn "sshd"
  fi
  systemctl --user enable --now pipewire.service 2>/dev/null || warn "pipewire.service"
  systemctl --user enable --now pipewire-pulse.service 2>/dev/null || warn "pipewire-pulse.service"
  systemctl --user enable --now wireplumber.service 2>/dev/null || warn "wireplumber.service"
  if command -v xdg-user-dirs-update >/dev/null 2>&1; then
    LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8 xdg-user-dirs-update --force
    ok "xdg-user-dirs (pt-BR)"
  fi
}

install_yay() {
  if command -v yay >/dev/null 2>&1; then
    ok "yay já instalado"
    return 0
  fi
  need_sudo
  sudo pacman -S --needed --noconfirm base-devel git
  local tmp
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
}

install_aur_extras() {
  install_yay
  local -a aur_packages=()
  if [[ -f "$INSTALL_DIR/packages-aur.txt" ]]; then
    readarray -t aur_packages < <(grep -v '^#' "$INSTALL_DIR/packages-aur.txt" | grep -v '^[[:space:]]*$' || true)
  else
    aur_packages=(nwg-look waypaper xfce-polkit)
  fi
  [[ ${#aur_packages[@]} -gt 0 ]] || return 0
  log "Pacotes AUR (${#aur_packages[@]}): ${aur_packages[*]}"
  yay -S --needed --noconfirm --answerclean All --answerdiff None --answerupgrade None --removemake \
    "${aur_packages[@]}" || warn "Falha parcial AUR"
}

readarray -t PACMAN_PACKAGES < <(grep -v '^#' "$INSTALL_DIR/packages.txt" | grep -v '^[[:space:]]*$' || true)

install_pacman_packages() {
  [[ ${#PACMAN_PACKAGES[@]} -gt 0 ]] || return 0
  need_sudo
  log "Pacotes pacman (${#PACMAN_PACKAGES[@]})"
  if sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"; then
    ok "Pacotes pacman instalados"
  else
    local pkg
    for pkg in "${PACMAN_PACKAGES[@]}"; do
      sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null || warn "pacman falhou: $pkg"
    done
  fi
}

apply_runtime_theme() {
  local theme="${1:-catppuccin-frappe}"
  local hypr_dir="${2:-$HYPR_DEST}"
  local scripts="$THEMES_DEST/scripts"
  bash "$scripts/chmod-scripts.sh"
  bash "$scripts/setup-wlogout-icons.sh" "$THEMES_DEST/wlogout/icons" 2>/dev/null || true
  # shellcheck source=/dev/null
  source "$scripts/lib/runtime-links.sh"
  apply_runtime_links "$THEMES_DEST" "$theme" 0
  echo "$theme" >"$THEMES_DEST/state"
  link_hypr_theme_files "$hypr_dir"
}
