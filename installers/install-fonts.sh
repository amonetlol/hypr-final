#!/usr/bin/env bash
# Fontes: pacman (0xProto, Geist mono nerd) + dot Assets/.fonts → ~/.fonts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS="$REPO_ROOT/Assets"

log() { printf "[*] %s\n" "$1"; }
ok() { printf "[OK] %s\n" "$1"; }

install_pacman_fonts() {
  # shellcheck source=lib/sudo.sh
  source "$SCRIPT_DIR/lib/sudo.sh"
  sudo pacman -S --needed --noconfirm ttf-0xproto-nerd otf-geist-mono-nerd fontconfig
  ok "ttf-0xproto-nerd + otf-geist-mono-nerd"
}

install_dot_fonts() {
  local src="$ASSETS/.fonts"
  if [[ ! -d "$src" ]]; then
    log "Assets/.fonts ausente — rode: bash Assets/vendor-assets.sh --fonts"
    return 0
  fi
  mkdir -p "$HOME/.fonts"
  cp -a "$src/." "$HOME/.fonts/"
  ok "~/.fonts ($(find "$HOME/.fonts" -type f | wc -l) ficheiros)"
}

install_pacman_fonts
install_dot_fonts
fc-cache -fv "$HOME/.fonts" 2>/dev/null || fc-cache -fv
ok "fontconfig atualizado"
