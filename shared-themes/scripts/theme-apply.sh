#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(dirname "$SCRIPT_DIR")"
STATE_FILE="$THEMES_DIR/state"
PACKS_DIR="$THEMES_DIR/packs"
# shellcheck source=lib/runtime-links.sh
source "$SCRIPT_DIR/lib/runtime-links.sh"
# shellcheck source=lib/session-detect.sh
source "$SCRIPT_DIR/lib/session-detect.sh"
# shellcheck source=lib/wallpaper.sh
source "$SCRIPT_DIR/lib/wallpaper.sh"
# shellcheck source=lib/matugen.sh
source "$SCRIPT_DIR/lib/matugen.sh"

usage() {
  echo "Usage: $(basename "$0") [--theme NAME] [--dry-run] [--no-wallpaper]"
  exit 1
}

DRY_RUN=0
NO_WALLPAPER=0
THEME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --theme) THEME="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --no-wallpaper) NO_WALLPAPER=1; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$THEME" ]]; then
  [[ -f "$STATE_FILE" ]] || { echo "No theme in state and --theme not given"; exit 1; }
  THEME="$(<"$STATE_FILE")"
fi

PACK_DIR="$PACKS_DIR/$THEME"
MANIFEST="$PACK_DIR/manifest.toml"

[[ -d "$PACK_DIR" ]] || { echo "Theme pack not found: $THEME"; exit 1; }
[[ -f "$MANIFEST" ]] || { echo "Missing manifest: $MANIFEST"; exit 1; }

if [[ "$THEME" == "matugen" ]] && ! matugen_generated_ok "$THEMES_DIR"; then
  wp="$(pick_matugen_wallpaper "$THEMES_DIR" || true)"
  if [[ -n "$wp" ]]; then
    echo "Matugen: generating colors from $wp"
    run_matugen "$THEMES_DIR" "$wp"
  else
    echo "WARN: Matugen selected but no wallpaper — run setup-matugen.sh and matugen-apply.sh"
    notify-send -u low "Theme" "Matugen: pick a wallpaper first (SUPER+SHIFT+T)" 2>/dev/null || true
  fi
fi

apply_runtime_links "$THEMES_DIR" "$THEME" "$DRY_RUN"

if [[ $DRY_RUN -eq 0 ]]; then
  echo "$THEME" >"$STATE_FILE"
fi

if [[ $DRY_RUN -eq 1 ]]; then
  for _d in "$HOME/.config/hypr" "$HOME/.config/hyprtheme"; do
    [[ -d "$_d" ]] || continue
    echo "LINK $_d/theme.conf -> $THEMES_DIR/hypr/theme.conf"
    echo "LINK $_d/theme.lua -> $THEMES_DIR/hypr/theme.lua"
  done
else
  link_all_hypr_theme_files "$THEMES_DIR"
fi

if [[ $NO_WALLPAPER -eq 0 && "$THEME" != "matugen" ]]; then
  wp_line="$(grep -E '^wallpaper\s*=' "$MANIFEST" | head -1 | cut -d= -f2- | tr -d ' "')"
  if wp="$(resolve_wallpaper_path "$wp_line" "$THEME")"; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "WALLPAPER $wp"
    else
      apply_wallpaper "$wp" || notify-send -u low "Theme" "Failed to set wallpaper: $wp" 2>/dev/null || true
    fi
  else
    notify-send -u low "Theme" "Wallpaper not found for: $THEME" 2>/dev/null || true
  fi
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run complete for theme: $THEME"
  exit 0
fi

hyprctl reload 2>/dev/null || true
if pgrep -x waybar >/dev/null; then
  pkill -SIGUSR2 waybar 2>/dev/null || { pkill waybar; sleep 0.3; waybar & }
fi
makoctl reload 2>/dev/null || true
pkill -SIGUSR1 kitty 2>/dev/null || true
pkill -SIGUSR1 foot 2>/dev/null || true

notify-send -u normal "Theme" "Applied: $THEME" -t 2500 2>/dev/null || true
