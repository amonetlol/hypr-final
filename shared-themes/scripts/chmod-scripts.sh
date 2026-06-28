#!/usr/bin/env bash
# Make all bash scripts executable under themes/scripts and rofi/scripts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(dirname "$SCRIPT_DIR")"

chmod_bash_scripts() {
  local root="$1"
  local f

  while IFS= read -r -d '' f; do
    head -1 "$f" | grep -qE '^#!.*(ba)sh' || continue
    chmod +x "$f"
    echo "chmod +x $f"
  done < <(find "$root/scripts" "$root/rofi/scripts" -type f -print0 2>/dev/null)
}

chmod_bash_scripts "$THEMES_DIR"

if [[ -d "$THEMES_DIR/waybar/scripts" ]]; then
  for f in "$THEMES_DIR/waybar/scripts"/*.py; do
    [[ -f "$f" ]] || continue
    chmod +x "$f"
    echo "chmod +x $f"
  done
fi
