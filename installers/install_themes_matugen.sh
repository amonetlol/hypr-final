#!/usr/bin/env bash
# Matugen + hyprlock + tema pack default.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

THEME="catppuccin-frappe"
SKIP_MATUGEN_INSTALL=0
HYPR_CFG_DIR="${HYPR_CFG_DIR:-$HYPR_DEST}"

usage() {
  cat <<EOF
Uso: $(basename "$0") [opções]

Recovery: Matugen + hypr configs + aplica tema pack.

Opções:
  --theme NAME           Pack (default: catppuccin-frappe)
  --skip-matugen-install Pula pacman matugen/awww
  --hypr-dir PATH        ~/.config/hypr ou ~/.config/hyprtheme
  -h, --help
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --theme) THEME="$2"; shift 2 ;;
    --skip-matugen-install) SKIP_MATUGEN_INSTALL=1; shift ;;
    --hypr-dir) HYPR_CFG_DIR="$2"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) die "Opção desconhecida: $1" ;;
  esac
done

[[ -d "$THEMES_DEST/packs" ]] || copy_themes

deploy_hypr_configs "$HYPR_CFG_DIR"
setup_hyprlock_wallpaper

args=()
[[ $SKIP_MATUGEN_INSTALL -eq 1 ]] && args+=(--skip-install)
bash "$THEMES_DEST/scripts/setup-matugen.sh" "${args[@]}"

echo "$THEME" >"$THEMES_DEST/state"
apply_runtime_theme "$THEME" "$HYPR_CFG_DIR"
bash "$THEMES_DEST/scripts/theme-apply.sh" --theme "$THEME" || warn "theme-apply offline?"

ok "install_themes_matugen (tema: $THEME, hypr: $HYPR_CFG_DIR)"
