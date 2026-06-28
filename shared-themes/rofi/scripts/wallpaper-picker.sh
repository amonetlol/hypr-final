#!/usr/bin/env bash
set -euo pipefail

ROFI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WALLPAPER_DIR="$HOME/Imagens/wallpapers"
THEME="$(readlink -f "$ROFI_DIR/active/wallpaper.rasi")"

[[ -d "$WALLPAPER_DIR" ]] || { notify-send "Wallpaper" "Directory not found: $WALLPAPER_DIR"; exit 1; }

mapfile -t files < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' | sort -V)

if [[ ${#files[@]} -eq 0 ]]; then
  notify-send "Wallpaper" "No images in $WALLPAPER_DIR"
  exit 1
fi

# Pipe null-delimited icon entries directly — never store in a bash variable
selected="$(
  {
    for f in "${files[@]}"; do
      printf '%s\0icon\x1f%s\n' "$f" "$WALLPAPER_DIR/$f"
    done
  } | rofi -dmenu -i -p "Wallpaper" -theme "$THEME"
)"

[[ -z "$selected" ]] && exit 0

if [[ -f "$selected" ]]; then
  wp="$selected"
elif [[ -f "$WALLPAPER_DIR/$selected" ]]; then
  wp="$WALLPAPER_DIR/$selected"
else
  notify-send "Wallpaper" "File not found: $selected"
  exit 1
fi

if command -v awww >/dev/null 2>&1; then
  awww img "$wp" --transition-type grow --transition-fps 60
else
  notify-send -u low "Wallpaper" "awww not found" 2>/dev/null || true
  exit 1
fi

notify-send -u low "Wallpaper" "Applied: $(basename "$wp")" 2>/dev/null || true
