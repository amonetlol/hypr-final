#!/usr/bin/env bash
# Resolve wallpaper path from manifest (flexible name/extension).

_stem_eq() {
  local file="$1" id="$2"
  local base stem
  base="$(basename "$file")"
  stem="${base%.*}"
  [[ "${stem,,}" == "${id,,}" ]]
}

resolve_wallpaper_path() {
  local manifest_path="$1"
  local theme_id="$2"
  local wp dir f

  wp="${manifest_path/#\~/$HOME}"

  if [[ -f "$wp" ]]; then
    echo "$wp"
    return 0
  fi

  dir="$(dirname "$wp")"
  [[ -d "$dir" ]] || return 1

  # Exact stem match: nord.jpg yes, nordic.png no (for theme nord)
  while IFS= read -r -d '' f; do
    if _stem_eq "$f" "$theme_id"; then
      echo "$f"
      return 0
    fi
  done < <(find "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0 2>/dev/null)

  return 1
}

apply_wallpaper() {
  local wp="$1"
  if command -v awww >/dev/null 2>&1; then
    awww img "$wp" --transition-type grow --transition-fps 60
  else
    return 1
  fi
}
