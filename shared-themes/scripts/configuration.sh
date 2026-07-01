#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(dirname "$SCRIPT_DIR")"
ROFI_THEME="$THEMES_DIR/rofi/active/menu.rasi"
# shellcheck source=lib/session-detect.sh
source "$SCRIPT_DIR/lib/session-detect.sh"

if [[ $# -gt 2 || ( $# -ge 1 && "$1" != "standalone" && "$1" != "menu" ) ]]; then
  echo "Usage: $0 [menu|standalone] [previous_menu]"
  exit 1
fi

options=$(printf " Hyprland\n Theme Engine\n Waybar\n Rofi\n Foot\n Kitty\n Alacritty\n Mako\n Wlogout\n Theme Packs\n Wallpapers\n Neovim\n Starship\n Fastfetch" \
  | rofi -i -dmenu -p " Configuration" -theme "$ROFI_THEME")

[[ -z "$options" ]] && exit 0

open_dir() {
  foot_nvim "$1"
}

case "$options" in
  *Hyprland*)       open_dir "$(hypr_config_dir)" ;;
  *Theme\ Engine*)  open_dir "$THEMES_DIR/scripts" ;;
  *Waybar*)         open_dir "$THEMES_DIR/waybar" ;;
  *Rofi*)           open_dir "$THEMES_DIR/rofi" ;;
  *Foot*)           open_dir "$THEMES_DIR/foot" ;;
  *Kitty*)          open_dir "$THEMES_DIR/kitty" ;;
  *Alacritty*)      open_dir "$THEMES_DIR/alacritty" ;;
  *Mako*)           open_dir "$THEMES_DIR/mako" ;;
  *Wlogout*)        open_dir "$THEMES_DIR/wlogout" ;;
  *Theme\ Packs*)   open_dir "$THEMES_DIR/packs" ;;
  *Wallpapers*)     open_dir "$HOME/Imagens/wallpapers" ;;
  *Neovim*)
    foot_nvim +'lua Snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") })' 2>/dev/null \
      || foot_nvim "$HOME/.config/nvim"
    ;;
  *Starship*)       foot_nvim "$THEMES_DIR/starship/starship.toml" ;;
  *Fastfetch*)      foot_nvim "$HOME/.config/fastfetch/config.jsonc" ;;
  *)
    notify-send -u normal "Configuration" "Unknown option."
    ;;
esac
