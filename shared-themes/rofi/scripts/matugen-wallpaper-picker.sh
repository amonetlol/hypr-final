#!/usr/bin/env bash
# Wallpaper picker → Matugen colors + apply theme matugen.
set -euo pipefail

ROFI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="$(dirname "$ROFI_DIR")"
WALLPAPER_DIR="$HOME/Imagens/wallpapers"
THEME="$(readlink -f "$ROFI_DIR/active/wallpaper.rasi")"
MATUGEN_APPLY="$THEMES_DIR/scripts/matugen-apply.sh"

[[ -d "$WALLPAPER_DIR" ]] || { notify-send "Wallpaper" "Directory not found: $WALLPAPER_DIR"; exit 1; }

mapfile -t files < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' | sort -V)

if [[ ${#files[@]} -eq 0 ]]; then
  notify-send "Wallpaper" "No images in $WALLPAPER_DIR"
  exit 1
fi

selected="$(
  {
    for f in "${files[@]}"; do
      printf '%s\0icon\x1f%s\n' "$f" "$WALLPAPER_DIR/$f"
    done
  } | rofi -dmenu -i -p " Matugen" -theme "$THEME"
)"

[[ -z "$selected" ]] && exit 1

if [[ -f "$selected" ]]; then
  wp="$selected"
elif [[ -f "$WALLPAPER_DIR/$selected" ]]; then
  wp="$WALLPAPER_DIR/$selected"
else
  notify-send "Wallpaper" "File not found: $selected"
  exit 1
fi

exec bash "$MATUGEN_APPLY" --image "$wp"
