#!/usr/bin/env bash
# Catppuccin GTK + MacTahoe icons + Qogir cursors — de Assets/ (offline).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS="$REPO_ROOT/Assets"
THEMES_DIR="${HOME}/.themes"
ICONS_DIR="${HOME}/.icons"

log() { printf "[*] %s\n" "$1"; }
ok() { printf "[OK] %s\n" "$1"; }
die() { printf "[ERRO] %s\n" "$1" >&2; exit 1; }

[[ -d "$ASSETS" ]] || die "Assets/ ausente — rode: bash Assets/vendor-assets.sh"

install_catppuccin_gtk() {
  local zip=""
  for candidate in \
    "$ASSETS/catppuccin-frappe-blue.zip" \
    "$ASSETS/catppuccin-frappe-blue-standard+default.zip"; do
    if [[ -f "$candidate" ]]; then
      zip="$candidate"
      break
    fi
  done
  [[ -n "$zip" ]] || die "catppuccin-frappe-blue.zip ausente em Assets/ ou install/TO_CURSOR/"
  mkdir -p "$THEMES_DIR"
  unzip -oq "$zip" -d "$THEMES_DIR"
  ok "GTK catppuccin-frappe-blue → $THEMES_DIR (de $(basename "$zip"))"
}

install_icons() {
  [[ -f "$ASSETS/MacTahoe.tar.xz" ]] || die "MacTahoe.tar.xz ausente"
  mkdir -p "$ICONS_DIR"
  tar --no-same-owner -xJf "$ASSETS/MacTahoe.tar.xz" -C "$ICONS_DIR"
  ok "Ícones MacTahoe → $ICONS_DIR"
}

install_cursors() {
  [[ -f "$ASSETS/Qogir-cursors.tar.xz" ]] || die "Qogir-cursors.tar.xz ausente"
  mkdir -p "$ICONS_DIR"
  tar --no-same-owner -xJf "$ASSETS/Qogir-cursors.tar.xz" -C "$ICONS_DIR"
  ok "Cursors Qogir → $ICONS_DIR"
}

apply_gtkthemes() {
  local gtk="$HOME/.config/hypr/scripts/gtkthemes"
  local src="$REPO_ROOT/shared-themes/hypr/scripts/gtkthemes"
  mkdir -p "$HOME/.config/hypr/scripts"
  cp -f "$src" "$gtk"
  chmod +x "$gtk"
  log "Aplicando gtkthemes..."
  bash "$gtk"
  ok "gtkthemes aplicado"
}

log "=== GTK / ícones / cursor (Assets) ==="
install_catppuccin_gtk
install_icons
install_cursors
apply_gtkthemes
