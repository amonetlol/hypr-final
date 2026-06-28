#!/usr/bin/env bash
# Setup inicial: copia shared-themes → ~/.config/themes + runtime links.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

DRY_RUN=0
THEME="catppuccin-frappe"
SKIP_GENERATE=0
HYPR_CFG_DIR="${HYPR_CFG_DIR:-$HYPR_DEST}"

usage() {
  cat <<EOF
Uso: $(basename "$0") [opções]

Copia shared-themes para ~/.config/themes e prepara symlinks.

Opções:
  --dry-run         Mostra ações
  --theme NAME      Tema inicial (default: catppuccin-frappe)
  --skip-generate   Não roda generate-packs.sh
  --hypr-dir PATH   Dir Hyprland para theme.conf link (default: ~/.config/hypr)
  -h, --help
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --theme) THEME="$2"; shift 2 ;;
    --skip-generate) SKIP_GENERATE=1; shift ;;
    --hypr-dir) HYPR_CFG_DIR="$2"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) die "Opção desconhecida: $1" ;;
  esac
done

[[ $DRY_RUN -eq 1 ]] && { log "[dry-run] setup_inicial_themes"; exit 0; }

copy_themes
[[ $SKIP_GENERATE -eq 0 ]] && bash "$THEMES_DEST/scripts/generate-packs.sh"
apply_runtime_theme "$THEME" "$HYPR_CFG_DIR"
bash "$THEMES_DEST/scripts/theme-apply.sh" --theme "$THEME" || warn "theme-apply offline?"

ok "setup_inicial_themes (tema: $THEME)"
