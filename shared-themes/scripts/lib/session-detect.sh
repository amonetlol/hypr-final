#!/usr/bin/env bash
# Sessão Hypr ativa: ~/.config/hypr vs ~/.config/hyprtheme

hypr_config_dir() {
  if pgrep -af "Hyprland|start-hyprland" | grep -Fq -- "--config ${HOME}/.config/hyprtheme/"; then
    echo "$HOME/.config/hyprtheme"
  else
    echo "$HOME/.config/hypr"
  fi
}

themes_foot_ini() {
  local themes="${1:-${XDG_CONFIG_HOME:-$HOME/.config}/themes}"
  echo "$themes/foot/foot.ini"
}

foot_nvim() {
  foot -c "$(themes_foot_ini)" nvim "$@"
}

link_hypr_theme_files_in() {
  local themes_dir="$1"
  local hypr_dir="$2"
  [[ -d "$hypr_dir" ]] || return 0
  mkdir -p "$hypr_dir"
  ln -sfn "$themes_dir/hypr/theme.conf" "$hypr_dir/theme.conf"
  ln -sfn "$themes_dir/hypr/theme.lua" "$hypr_dir/theme.lua"
}

link_all_hypr_theme_files() {
  local themes_dir="$1"
  local cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
  link_hypr_theme_files_in "$themes_dir" "$cfg/hypr"
  link_hypr_theme_files_in "$themes_dir" "$cfg/hyprtheme"
}
