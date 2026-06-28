#!/usr/bin/env bash
# Instalação completa Hyprland — máquina nova (Arch/CachyOS).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

SKIP_THEMES=0
SKIP_SDDM=0
SKIP_DOTFILES=0
SKIP_CHAOTIC=0
SKIP_WALLS=0

usage() {
  cat <<EOF
Uso: $(basename "$0") [opções]

Instalação Hyprland full → ~/.config/hypr (conf padrão + hyprland.lua.example).

Opções:
  --skip-themes      Não roda setup_inicial_themes / install_themes_matugen
  --skip-sddm        Não instala SDDM
  --skip-dotfiles    Não copia dotfiles
  --skip-chaotic     Não configura Chaotic-AUR
  --skip-walls       Não clona wall2
  -h, --help
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-themes) SKIP_THEMES=1; shift ;;
    --skip-sddm) SKIP_SDDM=1; shift ;;
    --skip-dotfiles) SKIP_DOTFILES=1; shift ;;
    --skip-chaotic) SKIP_CHAOTIC=1; shift ;;
    --skip-walls) SKIP_WALLS=1; shift ;;
    -h|--help) usage 0 ;;
    *) die "Opção desconhecida: $1" ;;
  esac
done

install_prompt_sudo_password
install_sudo_init

INSTALL_LOG="$REPO_ROOT/install.log"
printf '\n=== Install full %s ===\n' "$(date -Iseconds)" >>"$INSTALL_LOG"
exec > >(tee -a "$INSTALL_LOG") 2>&1

[[ -f /etc/arch-release ]] || warn "Não parece Arch Linux — continuando."

log "=== 1/10 VMware ==="
bash "$INSTALL_DIR/install-vmware.sh" || warn "VMware tools ignorado"

log "=== 1b/10 Sync repositórios ==="
sudo pacman -Sy --noconfirm || warn "pacman -Sy falhou"

log "=== 2/10 Pacotes pacman ==="
install_pacman_packages

log "=== 2b/10 Fontes ==="
bash "$INSTALL_DIR/install-fonts.sh" || warn "Fontes falharam"

log "=== 3/10 yay-bin + AUR ==="
install_aur_extras

log "=== 4/10 GTK / ícones / cursor ==="
bash "$INSTALL_DIR/install-gtk-assets.sh" || warn "GTK assets falhou"

if [[ $SKIP_SDDM -eq 0 ]]; then
  log "=== 5/10 SDDM ==="
  bash "$INSTALL_DIR/install-sddm-theme.sh" || warn "SDDM falhou"
fi

if [[ $SKIP_DOTFILES -eq 0 ]]; then
  log "=== 6/10 Dotfiles ==="
  deploy_dotfiles
fi

log "=== 7/10 Theme engine + Hypr configs ==="
copy_themes
deploy_hypr_configs "$HYPR_DEST"
link_hypr_theme_files "$HYPR_DEST"
setup_hyprlock_wallpaper

if [[ $SKIP_WALLS -eq 0 ]]; then
  log "=== 8/10 Wallpapers ==="
  clone_wallpapers
  setup_hyprlock_wallpaper
fi

log "=== 9/10 Serviços + pós-instalação ==="
enable_services
bash "$INSTALL_DIR/post-install.sh" || warn "Pós-instalação falhou"

if [[ $SKIP_THEMES -eq 0 ]]; then
  log "=== 10/10 Temas ==="
  bash "$INSTALL_DIR/setup_inicial_themes.sh" --skip-generate
  bash "$INSTALL_DIR/install_themes_matugen.sh"
fi

if [[ $SKIP_CHAOTIC -eq 0 ]]; then
  bash "$INSTALL_DIR/chaotic-aur.sh" || warn "Chaotic-AUR falhou"
fi

bash "$INSTALL_DIR/modulos_standalone/run.sh" || warn "modulos_standalone falhou"

cat <<EOF

Instalação full concluída.
Log: $INSTALL_LOG

  Sessão SDDM: Hyprland
  Config:      ~/.config/hypr/hyprland.conf (padrão)
  Lua alt:     ~/.config/hypr/hyprland.lua.example
  Trocar:      echo lua > ~/.config/hypr/.format && cp hyprland.lua.example hyprland.lua

  Super+F1 cheatsheet  |  Super+T tema  |  Super+Shift+T Matugen

EOF
