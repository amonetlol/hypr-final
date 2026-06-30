#!/usr/bin/env bash
# Pós-instalação: XDG pt-BR, Thunar, hide-shortcuts, nvim (clone), gtkthemes, runtime links.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

log "=== Pós-instalação ==="

setup_xdg_ptbr() {
  log "XDG user-dirs (pt-BR)"
  export LANG=pt_BR.UTF-8
  export LC_ALL=pt_BR.UTF-8
  xdg-user-dirs-update --force
  local dirs="$HOME/.config/user-dirs.dirs"
  if [[ -f "$dirs" ]]; then
    sed -i 's|XDG_DESKTOP_DIR=.*|XDG_DESKTOP_DIR="$HOME/Desktop"|' "$dirs"
    sed -i 's|XDG_DOWNLOAD_DIR=.*|XDG_DOWNLOAD_DIR="$HOME/Downloads"|' "$dirs"
    sed -i 's|XDG_DOCUMENTS_DIR=.*|XDG_DOCUMENTS_DIR="$HOME/Documentos"|' "$dirs"
    sed -i 's|XDG_PICTURES_DIR=.*|XDG_PICTURES_DIR="$HOME/Imagens"|' "$dirs"
    sed -i 's|XDG_VIDEOS_DIR=.*|XDG_VIDEOS_DIR="$HOME/Vídeos"|' "$dirs"
  fi
  xdg-user-dirs-update --force
  mkdir -p \
    "$HOME/Desktop" \
    "$HOME/Documentos" \
    "$HOME/Downloads" \
    "$HOME/Imagens/wallpapers" \
    "$HOME/Vídeos"
  ok "xdg-user-dirs pt-BR (Desktop=$HOME/Desktop)"
}

setup_thunar_bookmarks() {
  log "Thunar bookmarks"
  mkdir -p "$HOME/.config/gtk-3.0"
  cat >"$HOME/.config/gtk-3.0/bookmarks" <<EOF
file://${HOME}/Desktop Desktop
file://${HOME}/Documentos Documentos
file://${HOME}/Downloads Downloads
file://${HOME}/Imagens Imagens
file://${HOME}/Vídeos Vídeos
file://${HOME}/Imagens/wallpapers wallpapers
EOF
  ok "Thunar bookmarks"
}

setup_xdg_ptbr
setup_thunar_bookmarks

log "Reparar runtime links (rofi/waybar/foot)"
bash "$SCRIPT_DIR/repair-runtime-links.sh" || warn "repair-runtime-links falhou"

log "hide-shortcuts"
bash "$SCRIPT_DIR/hide-shortcuts.sh" || warn "hide-shortcuts falhou parcialmente"

for hypr_dir in "$HOME/.config/hypr" "$HOME/.config/hyprtheme"; do
  if [[ -x "$hypr_dir/scripts/gtkthemes" ]]; then
    export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
    bash "$hypr_dir/scripts/gtkthemes" || warn "gtkthemes falhou ($hypr_dir)"
    ok "gtkthemes ($hypr_dir)"
  fi
done

bash "$SCRIPT_DIR/setup-nvim.sh" || warn "setup-nvim falhou"

ok "Pós-instalação concluída"
