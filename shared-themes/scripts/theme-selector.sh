#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(dirname "$SCRIPT_DIR")"
PACKS_DIR="$THEMES_DIR/packs"
ROFI_THEME="$THEMES_DIR/rofi/active/menu.rasi"

mapfile -t themes < <(find "$PACKS_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '_*' -printf '%f\n' 2>/dev/null | sort)
if [[ ${#themes[@]} -eq 0 ]]; then
  mapfile -t themes < <(find "$PACKS_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '_*' -exec basename {} \; | sort)
fi

if [[ ${#themes[@]} -eq 0 ]]; then
  notify-send -u critical "Theme" "No theme packs found in $PACKS_DIR"
  exit 1
fi

theme_display_name() {
  local t="$1"
  if [[ -f "$PACKS_DIR/$t/manifest.toml" ]]; then
    local n
    n="$(grep -E '^name\s*=' "$PACKS_DIR/$t/manifest.toml" | head -1 | cut -d= -f2- | tr -d ' "')"
    [[ -n "$n" ]] && { echo "$n"; return; }
  fi
  echo "$t"
}

current=""
[[ -f "$THEMES_DIR/state" ]] && current="$(<"$THEMES_DIR/state")"

menu=""
for t in "${themes[@]}"; do
  label="$(theme_display_name "$t")"
  [[ "$t" == "$current" ]] && label="󰄬 $label"
  menu+="$label"$'\n'
done

chosen="$(printf '%s' "$menu" | rofi -i -dmenu -p " Theme" -theme "$ROFI_THEME" 2>/dev/null || true)"
[[ -z "$chosen" ]] && exit 0

# Strip active marker and whitespace
chosen="$(sed 's/^󰄬[[:space:]]*//' <<<"$chosen" | xargs)"

resolve_theme_id() {
  local selection="$1"
  local t name best_id="" best_len=0

  # 1) Exact match on display name or pack id
  for t in "${themes[@]}"; do
    name="$(theme_display_name "$t")"
    if [[ "$selection" == "$name" || "$selection" == "$t" ]]; then
      echo "$t"
      return 0
    fi
  done

  # 2) Longest partial match (nordic before nord)
  for t in "${themes[@]}"; do
    name="$(theme_display_name "$t")"
    for candidate in "$name" "$t"; do
      if [[ "$selection" == *"$candidate"* ]] && [[ ${#candidate} -gt $best_len ]]; then
        best_len=${#candidate}
        best_id="$t"
      fi
    done
  done

  [[ -n "$best_id" ]] && { echo "$best_id"; return 0; }
  return 1
}

if ! theme_id="$(resolve_theme_id "$chosen")"; then
  notify-send "Theme" "Could not resolve selection: $chosen"
  exit 1
fi

if [[ "$theme_id" == "matugen" ]]; then
  exec "$THEMES_DIR/rofi/scripts/matugen-wallpaper-picker.sh"
fi

exec "$SCRIPT_DIR/theme-apply.sh" --theme "$theme_id"
