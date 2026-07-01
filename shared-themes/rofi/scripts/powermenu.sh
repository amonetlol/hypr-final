#!/usr/bin/env bash
# Power menu (rofi) — Hyprland + SDDM.
# Chamado por: action.sh --power  (Super+X, waybar)

set -euo pipefail

die() { printf "[ERRO] %s\n" "$1" >&2; exit 1; }
warn() { printf "[AVISO] %s\n" "$1"; }

ROFI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="$(dirname "$ROFI_DIR")"
# shellcheck source=../../scripts/lib/session-detect.sh
source "$THEMES_DIR/scripts/lib/session-detect.sh"
resolve_rasi() {
  local name="$1"
  local candidate
  candidate="$(readlink -f "$ROFI_DIR/active/${name}.rasi" 2>/dev/null || true)"
  if [[ -f "$candidate" ]]; then
    echo "$candidate"
    return
  fi
  candidate="$ROFI_DIR/../packs/catppuccin-frappe/rofi/${name}.rasi"
  [[ -f "$candidate" ]] && echo "$candidate" && return
  die "Tema rofi ausente: ${name}.rasi (corra: bash install/repair-runtime-links.sh)"
}
RASI="$(resolve_rasi powermenu)"

prompt="$(hostname) (${XDG_CURRENT_DESKTOP:-Hyprland})"
mesg="Uptime: $(uptime -p | sed 's/up //g')"

# Sem espaços à esquerda — evita mismatch no case após o rofi
options=$'Lock\nLogout\nSuspend\nHibernate\nReboot\nShutdown'

ensure_hypr_env() {
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" && -d "$XDG_RUNTIME_DIR/hypr" ]]; then
    HYPRLAND_INSTANCE_SIGNATURE="$(ls "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -1)"
    export HYPRLAND_INSTANCE_SIGNATURE
  fi
}

hyprland_running() {
  ensure_hypr_env
  [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null
}

do_logout() {
  # SDDM: sair do compositor volta ao greeter (não usar loginctl terminate-user)
  if hyprland_running; then
    hyprctl dispatch exit 2>/dev/null && return 0
    hyprctl kill 2>/dev/null && return 0
    pkill -x Hyprland 2>/dev/null && return 0
    warn "hyprctl exit falhou — tentando loginctl"
  fi
  if [[ -n "${XDG_SESSION_ID:-}" ]]; then
    loginctl terminate-session "$XDG_SESSION_ID" --no-ask-password
    return 0
  fi
  loginctl terminate-user "$USER" --no-ask-password
}

locky() {
  local lock
  lock="$(hypr_config_dir)/hyprlock.conf"
  if [[ -f "$lock" ]]; then
    hyprlock -c "$lock"
  else
    hyprlock
  fi
}

run_cmd() {
  case "$1" in
    lock)      locky ;;
    logout)    do_logout ;;
    suspend)   systemctl suspend ;;
    hibernate) systemctl hibernate ;;
    reboot)    systemctl reboot ;;
    shutdown)  systemctl poweroff ;;
    *)         return 1 ;;
  esac
}

chosen="$(echo -e "$options" | rofi -dmenu -p "$prompt" -mesg "$mesg" -theme "$RASI")"
[[ -z "${chosen:-}" ]] && exit 0

# Normaliza texto (rofi pode devolver espaços/markup)
chosen="$(printf '%s' "$chosen" | sed 's/<[^>]*>//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

case "$chosen" in
  Lock)      run_cmd lock ;;
  Logout)    run_cmd logout ;;
  Suspend)   run_cmd suspend ;;
  Hibernate) run_cmd hibernate ;;
  Reboot)    run_cmd reboot ;;
  Shutdown)  run_cmd shutdown ;;
  *)
    # fallback por substring (teclado / locale)
    case "$chosen" in
      *Lock*)      run_cmd lock ;;
      *Logout*|*Sair*) run_cmd logout ;;
      *Suspend*)   run_cmd suspend ;;
      *Hibernate*) run_cmd hibernate ;;
      *Reboot*|*Reiniciar*) run_cmd reboot ;;
      *Shutdown*|*Desligar*) run_cmd shutdown ;;
    esac
    ;;
esac
