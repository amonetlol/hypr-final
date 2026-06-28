#!/usr/bin/env bash
# HyprTheme (hypr-alt) — funções partilhadas

# shellcheck source=hypr-format.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/hypr-format.sh"

hypr_alt_remove_legacy_tree() {
  local base="${XDG_CONFIG_HOME:-$HOME/.config}/hyprtheme"
  local legacy="${base}/hypr/.config/hypr"
  if [[ -d "$legacy" || -L "$legacy" ]]; then
    log "Removendo path legado: $legacy"
    rm -rf "$legacy"
  fi
  rmdir "${base}/hypr/.config" 2>/dev/null || true
  rmdir "${base}/hypr" 2>/dev/null || true
}

hypr_alt_deploy_configs() {
  deploy_hypr_configs_to_dir "$1" "${2:-0}"
}

hypr_alt_link_runtime() {
  local hypr_dir="$1"
  local themes_dest="$2"
  local starship_dest="$3"
  local wlogout_dest="$4"
  local dry_run="${5:-0}"

  run() {
    if [[ "$dry_run" -eq 1 ]]; then
      printf "[dry-run] %s\n" "$*"
    else
      "$@"
    fi
  }

  log "Links runtime — sem tocar em ~/.config/hypr"
  mkdir -p "$hypr_dir"
  run ln -sfn "$themes_dest/hypr/theme.conf" "$hypr_dir/theme.conf"
  run ln -sfn "$themes_dest/hypr/theme.lua" "$hypr_dir/theme.lua"
  run ln -sfn "$themes_dest/wlogout" "$wlogout_dest"
  run ln -sfn "$themes_dest/starship/starship.toml" "$starship_dest"
  ok "theme.conf, theme.lua, wlogout, starship.toml"
}

hypr_alt_install_session_files() {
  local dry_run="${1:-0}"
  local launcher="/usr/bin/run-hyprland-theme"
  local session="/usr/share/wayland-sessions/hyprland-theme.desktop"
  local session_src="$DOTFILES_ALT/session"

  run() {
    if [[ "$dry_run" -eq 1 ]]; then
      printf "[dry-run] %s\n" "$*"
    else
      "$@"
    fi
  }

  log "Launcher + sessão Wayland (sudo) — SDDM não é alterado"
  run sudo install -m 755 "$session_src/run-hyprland-theme" "$launcher"
  run sudo install -m 644 "$session_src/hyprland-theme.desktop" "$session"
  ok "run-hyprland-theme (755) + hyprland-theme.desktop (644)"
}
