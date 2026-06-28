#!/usr/bin/env bash
# Repara symlinks runtime quebrados (ex.: apontam para Downloads/ ou matugen ausente).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

DEFAULT_THEME="${THEME_REPAIR_DEFAULT:-catppuccin-frappe}"
themes="$THEMES_DEST"

has_broken_runtime_links() {
  local link target
  for link in \
    "$themes/foot/colors.ini" \
    "$themes/waybar/colors.css" \
    "$themes/wlogout/colors.css" \
    "$themes/rofi/active" \
    "$themes/hypr/theme.conf"; do
    [[ -L "$link" ]] || continue
    target="$(readlink -f "$link" 2>/dev/null || true)"
    [[ -z "$target" || ! -e "$target" ]] && return 0
    if [[ "$target" == *"/Downloads/"* ]]; then
      return 0
    fi
  done
  return 1
}

resolve_repair_theme() {
  local state=""
  if [[ -f "$themes/state" ]]; then
    state="$(tr -d '[:space:]' <"$themes/state")"
  fi
  if [[ "$state" == "matugen" ]] && ! [[ -f "$themes/matugen/generated/foot/colors.ini" ]]; then
    warn "state=matugen mas generated ausente — usando $DEFAULT_THEME"
    echo "$DEFAULT_THEME"
    return
  fi
  if has_broken_runtime_links; then
    if [[ -n "$state" && -d "$themes/packs/$state" ]]; then
      echo "$state"
    else
      echo "$DEFAULT_THEME"
    fi
    return
  fi
  echo "${state:-$DEFAULT_THEME}"
}

log "=== Reparar runtime links ==="
theme="$(resolve_repair_theme)"
apply_runtime_theme "$theme"
bash "$themes/scripts/theme-apply.sh" --theme "$theme" 2>/dev/null || warn "theme-apply offline"
ok "Runtime links reparados (tema: $theme)"
