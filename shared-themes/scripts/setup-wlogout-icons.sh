#!/usr/bin/env bash
# Download wlogout button icons if missing.
set -euo pipefail

ICONS_DIR="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/wlogout/icons}"
BASE_URL="https://raw.githubusercontent.com/ArtsyMacaw/wlogout/master/assets"

mkdir -p "$ICONS_DIR"

fetch_icon() {
  local name="$1"
  local dest="$ICONS_DIR/$name.png"
  [[ -f "$dest" ]] && return 0
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$BASE_URL/$name.png" -o "$dest" && echo "Fetched: $name.png" && return 0
  fi
  return 1
}

for icon in lock logout suspend hibernate shutdown reboot; do
  fetch_icon "$icon" || echo "WARN: could not fetch $icon.png"
done

if [[ ! -f "$ICONS_DIR/lock.png" ]]; then
  echo "WARN: wlogout icons missing — copy manually to $ICONS_DIR"
  exit 1
fi

echo "Wlogout icons ready in $ICONS_DIR"
