#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(dirname "$SCRIPT_DIR")"
dir="${HOME}/.config/themes"
ROFI_DIR="$THEMES_DIR/rofi"

usage() {
  cat <<EOF
Usage: $(basename "$0") <flag>

Hub for Hyprland keybinds:
  --menu        Application launcher (drun)
  --clip        Clipboard history
  --wall        Wallpaper picker (does not change theme colors)
  --wall-matu   Wallpaper picker + Matugen dynamic theme
  --screen      Screenshot menu
  --power       Power menu
  --window      Window switcher
  --foot        Launch foot terminal
  --kitty       Launch kitty terminal
  --alacritty   Launch alacritty terminal
  --waybar      Restart waybar
  --log         Wlogout
EOF
  exit 1
}

[[ $# -eq 1 ]] || usage

rofi_theme() {
  readlink -f "$dir/rofi/active/$1.rasi"
}

case "$1" in
  --menu)
    exec rofi -show drun -theme "$(rofi_theme launcher)"
    ;;
  --clip)
    exec "$dir/rofi/scripts/cliphist.sh"
    ;;
  --wall)
    exec "$dir/rofi/scripts/wallpaper-picker.sh"
    ;;
  --wall-matu)
    exec "$dir/rofi/scripts/matugen-wallpaper-picker.sh"
    ;;
  --screen)
    exec "$dir/rofi/scripts/screenshot.sh"
    ;;
  --power)
    exec "$dir/rofi/scripts/powermenu.sh"
    ;;
  --window)
    exec rofi -show window -theme "$(rofi_theme window)"
    ;;
  --foot)
    exec foot -c "$dir/foot/foot.ini"
    ;;
  --kitty)
    exec kitty --config "$dir/kitty/kitty.conf"
    ;;
  --alacritty)
    exec alacritty --config-file "$dir/alacritty/alacritty.toml"
    ;;
  --waybar)
    pkill waybar 2>/dev/null || true
    sleep 0.2
    exec waybar -c "$dir/waybar/config.jsonc" -s "$dir/waybar/style.css"
    ;;
  --log)
    exec wlogout -p layer-shell
    ;;
  *)
    usage
    ;;
esac
