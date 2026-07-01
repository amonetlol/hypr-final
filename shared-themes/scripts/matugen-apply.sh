#!/usr/bin/env bash
# Generate colors from a wallpaper via Matugen and apply as active theme.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck source=lib/matugen.sh
source "$SCRIPT_DIR/lib/matugen.sh"
# shellcheck source=lib/wallpaper.sh
source "$SCRIPT_DIR/lib/wallpaper.sh"

IMAGE=""
FROM_STATE=0
APPLY_WALLPAPER=1

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

  --image PATH     Wallpaper image for Matugen
  --from-state     Use last matugen wallpaper (or first in ~/Imagens/wallpapers)
  --no-wallpaper   Skip setting wallpaper (only regenerate colors)
  -h, --help       Show help
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image) IMAGE="$2"; shift 2 ;;
    --from-state) FROM_STATE=1; shift ;;
    --no-wallpaper) APPLY_WALLPAPER=0; shift ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1"; usage 1 ;;
  esac
done

if [[ -z "$IMAGE" && $FROM_STATE -eq 1 ]]; then
  IMAGE="$(pick_matugen_wallpaper "$THEMES_DIR" || true)"
fi

if [[ -z "$IMAGE" ]]; then
  echo "ERROR: provide --image PATH or --from-state"
  usage 1
fi

ensure_matugen_pack "$THEMES_DIR"
write_matugen_config "$THEMES_DIR"

if ! run_matugen "$THEMES_DIR" "$IMAGE"; then
  notify-send -u critical "Matugen" "Failed to generate theme — check terminal output" 2>/dev/null || true
  exit 1
fi

if [[ $APPLY_WALLPAPER -eq 1 ]]; then
  apply_wallpaper "$IMAGE" || notify-send -u low "Wallpaper" "awww failed — colors were still applied" 2>/dev/null || true
fi

exec "$SCRIPT_DIR/theme-apply.sh" --theme matugen --no-wallpaper
