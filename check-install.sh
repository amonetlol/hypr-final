#!/usr/bin/env bash
# Verificação pós-instalação — full ou hypr-alt.

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS="$REPO_ROOT/installers"

printf "Checklist de verificação\n\n"
printf "  [1] Hypr full (~/.config/hypr)\n"
printf "  [2] Hypr-alt (~/.config/hyprtheme)\n"
printf "Escolha [1/2] (default: 1): "
read -r ans

case "${ans:-1}" in
  2|alt) MODE=alt ;;
  *) MODE=full ;;
esac

ok=0 warn=0 fail=0
pass() { printf "  [OK]   %s\n" "$1"; ok=$((ok + 1)); }
note() { printf "  [~~]   %s\n" "$1"; warn=$((warn + 1)); }
miss() { printf "  [FALTA] %s\n" "$1"; fail=$((fail + 1)); }
section() { printf "\n── %s ──\n" "$1"; }

has_pkg() { pacman -Q "$1" &>/dev/null; }
has_file() { [[ -e "$1" ]]; }

if [[ "$MODE" == "full" ]]; then
  HYPR_DIR="$HOME/.config/hypr"
  section "Hypr full"
  systemctl is-enabled sddm &>/dev/null && pass "SDDM enabled" || note "SDDM não enabled"
else
  HYPR_DIR="$HOME/.config/hyprtheme"
  section "Hypr-alt"
  has_file /usr/bin/run-hyprland-theme && pass "run-hyprland-theme" || miss "run-hyprland-theme"
  has_file /usr/share/wayland-sessions/hyprland-theme.desktop && pass "hyprland-theme.desktop" || miss "sessão HyprTheme"
fi

section "Theme engine"
has_file "$HOME/.config/themes/state" && pass "state: $(cat "$HOME/.config/themes/state")" || miss "themes/state"
has_file "$HOME/.config/themes/scripts/action.sh" && pass "action.sh" || miss "theme engine"

section "Hypr config ($HYPR_DIR)"
if has_file "$HYPR_DIR/.format"; then
  pass "formato: $(cat "$HYPR_DIR/.format")"
fi
has_file "$HYPR_DIR/hyprland.conf" && pass "hyprland.conf" || note "hyprland.conf"
has_file "$HYPR_DIR/hyprland.lua.example" && pass "hyprland.lua.example" || miss "hyprland.lua.example"
has_file "$HYPR_DIR/hyprlock.conf" && pass "hyprlock.conf" || miss "hyprlock.conf"
readlink -f "$HYPR_DIR/theme.conf" 2>/dev/null | grep -q theme.conf && pass "theme.conf symlink" || miss "theme.conf"

section "Pacotes core"
for pkg in hyprland hyprlock waybar wlogout rofi foot matugen python-requests; do
  has_pkg "$pkg" && pass "$pkg" || miss "$pkg"
done

section "Wallpapers"
wall="$HOME/Imagens/wallpapers"
[[ "$(find "$wall" -maxdepth 1 -type f 2>/dev/null | wc -l)" -gt 0 ]] \
  && pass "wallpapers em $wall" || note "wallpapers vazios"

printf "\n── Resumo ──\n  OK: %s  Avisos: %s  Falta: %s\n" "$ok" "$warn" "$fail"
printf "\nChecklist completo: installers/CHECKLIST_%s.md\n" "$MODE"
