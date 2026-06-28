#!/usr/bin/env bash
# Menu principal — Hyprland Theme Engine (final_release)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS="$REPO_ROOT/installers"

die() { printf "[ERRO] %s\n" "$1" >&2; exit 1; }

[[ -d "$REPO_ROOT/shared-themes/packs" ]] || die "shared-themes/packs ausente — repo incompleto?"

printf "Hyprland Theme Engine — instalador\n\n"
printf "  [1] Hypr full   — máquina nova (SDDM + ~/.config/hypr)\n"
printf "  [2] Hypr-alt    — sessão HyprTheme (~/.config/hyprtheme)\n"
printf "  [q] Sair\n\n"
printf "Escolha [1/2/q]: "
read -r ans

case "$ans" in
  1|full|Full|FULL)
    exec bash "$INSTALLERS/install_hypr-full.sh" "$@"
    ;;
  2|alt|Alt|ALT)
    exec bash "$INSTALLERS/install_hypr-alt.sh" "$@"
    ;;
  q|Q) exit 0 ;;
  *) die "Opção inválida: $ans" ;;
esac
