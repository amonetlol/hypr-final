#!/usr/bin/env bash
# Sessão HyprTheme — não mexe em ~/.config/hypr nem SDDM.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/hypr-alt-common.sh
source "$SCRIPT_DIR/lib/hypr-alt-common.sh"

THEME="catppuccin-frappe"
DRY_RUN=0

usage() {
  cat <<EOF
Uso: $(basename "$0") [opções]

HyprTheme → ~/.config/hyprtheme (conf padrão + hyprland.lua.example).
Não altera ~/.config/hypr nem SDDM.

Opções:
  --theme NAME   Tema inicial (default: catppuccin-frappe)
  --dry-run      Mostra ações sem alterar
  -h, --help
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --theme) THEME="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage 0 ;;
    *) die "Opção desconhecida: $1" ;;
  esac
done

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
HYPR_THEME_DIR="$CONFIG_HOME/hyprtheme"
THEMES_DEST="$CONFIG_HOME/themes"

apply_theme_runtime() {
  log "Runtime links (tema: $THEME)"
  [[ $DRY_RUN -eq 1 ]] && return 0
  bash "$THEMES_DEST/scripts/chmod-scripts.sh"
  bash "$THEMES_DEST/scripts/setup-wlogout-icons.sh" "$THEMES_DEST/wlogout/icons" 2>/dev/null || true
  # shellcheck source=/dev/null
  source "$THEMES_DEST/scripts/lib/runtime-links.sh"
  apply_runtime_links "$THEMES_DEST" "$THEME" 0
  echo "$THEME" >"$THEMES_DEST/state"
}

setup_matugen_config_only() {
  log "Matugen (config/dirs)"
  [[ $DRY_RUN -eq 1 ]] && return 0
  bash "$THEMES_DEST/scripts/setup-matugen.sh" --skip-install || warn "setup-matugen parcial"
}

install_prompt_sudo_password
install_sudo_init

log "=== hypr-alt: theme engine ==="
if [[ $DRY_RUN -eq 1 ]]; then
  log "[dry-run] copy_themes + matugen + runtime"
else
  copy_themes
  setup_matugen_config_only
  apply_theme_runtime
fi

log "=== hypr-alt: limpar path legado ==="
[[ $DRY_RUN -eq 0 ]] && hypr_alt_remove_legacy_tree

log "=== hypr-alt: ~/.config/hyprtheme ==="
hypr_alt_deploy_configs "$HYPR_THEME_DIR" "$DRY_RUN"
hypr_alt_link_runtime "$HYPR_THEME_DIR" "$THEMES_DEST" \
  "$CONFIG_HOME/starship.toml" "$CONFIG_HOME/wlogout" "$DRY_RUN"

log "=== hypr-alt: sessão HyprTheme ==="
hypr_alt_install_session_files "$DRY_RUN"

if [[ $DRY_RUN -eq 0 ]]; then
  HYPR_CFG_DIR="$HYPR_THEME_DIR" bash "$INSTALL_DIR/install_themes_matugen.sh" --skip-matugen-install --hypr-dir "$HYPR_THEME_DIR" || warn "matugen/theme parcial"
fi

ACTIVE="$(hypr_active_format "$HYPR_THEME_DIR")"

cat <<EOF

HyprTheme instalado.

  Formato ativo:  $ACTIVE (.format em $HYPR_THEME_DIR)
  Config:         $HYPR_THEME_DIR/hyprland.conf
  Lua alt:        $HYPR_THEME_DIR/hyprland.lua.example
  Sessão login:   HyprTheme
  ~/.config/hypr: não alterado

EOF
