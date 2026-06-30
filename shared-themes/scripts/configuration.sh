#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(dirname "$SCRIPT_DIR")"
ROFI_THEME="$THEMES_DIR/rofi/active/menu.rasi"
FOOT_DIR="$THEMES_DIR/foot/foot.ini"

if [[ $# -gt 2 || ( $# -ge 1 && "$1" != "standalone" && "$1" != "menu" ) ]]; then
  echo "Usage: $0 [menu|standalone] [previous_menu]"
  exit 1
fi

options=$(printf " Hyprland\n Theme Engine\n Waybar\n Rofi\n Foot\n Kitty\n Alacritty\n Mako\n Wlogout\n Theme Packs\n Wallpapers\n Neovim\n Starship\n Fastfetch" \
  | rofi -i -dmenu -p " Configuration" -theme "$ROFI_THEME")

[[ -z "$options" ]] && exit 0

open_dir() {
  foot -c "$FOOT_DIR" nvim "$1"
}

hypr_config_dir() {
  if pgrep -af "Hyprland|start-hyprland" | grep -Fq -- "--config ${HOME}/.config/hyprtheme/"; then
    echo "$HOME/.config/hyprtheme"
  else
    echo "$HOME/.config/hypr"
  fi
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
    foot nvim +'lua Snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") })' 2>/dev/null \
      || foot nvim "$HOME/.config/nvim"
    ;;

  *Starship*)       foot nvim "$THEMES_DIR/starship/starship.toml" ;;
  *Fastfetch*)      foot nvim "$HOME/.config/fastfetch/config.jsonc" ;;
  *)
    notify-send -u normal "Configuration" "Unknown option."
    ;;
esac
