#!/usr/bin/env bash
# Deploy Hyprland: conf ativo (padrão) + lua como .example

hypr_config_basename() {
  local hypr_dir="$1"
  basename "${hypr_dir/#\~/$HOME}"
}

hypr_render_paths() {
  local src="$1" dest="$2" cfg_name="$3"
  sed \
    -e "s|~/.config/hypr|~/.config/${cfg_name}|g" \
    -e "s|\"/.config/hypr/|\"/.config/${cfg_name}/|g" \
    "$src" >"$dest"
}

hypr_active_format() {
  local hypr_dir="$1"
  local fmt="conf"
  if [[ -f "$hypr_dir/.format" ]]; then
    fmt="$(<"$hypr_dir/.format")"
  fi
  case "$fmt" in
    lua) echo lua ;;
    *) echo conf ;;
  esac
}

# deploy_hypr_configs_to_dir DEST [DRY_RUN]
# Instala hyprland.conf + window-rules.conf + hyprland.lua.example + window-rules.lua.example
# .format controla qual formato o Hyprland usa (default: conf)
deploy_hypr_configs_to_dir() {
  local hypr_dir="$1"
  local dry_run="${2:-0}"
  local cfg_name active_format

  cfg_name="$(hypr_config_basename "$hypr_dir")"
  active_format="$(hypr_active_format "$hypr_dir")"

  run() {
    if [[ "$dry_run" -eq 1 ]]; then
      printf "[dry-run] %s\n" "$*"
    else
      "$@"
    fi
  }

  log "Hypr configs → $hypr_dir (ativo: $active_format, conf+lua.example instalados)"
  run mkdir -p "$hypr_dir/scripts"

  if [[ "$dry_run" -eq 1 ]]; then
    printf "[dry-run] hyprland.conf + hyprland.lua.example + hypridle/hyprlock\n"
  else
    hypr_render_paths "$THEMES_SRC/hypr/hyprland.conf.example" "$hypr_dir/hyprland.conf" "$cfg_name"
    cp -f "$THEMES_SRC/hypr/window-rules.conf" "$hypr_dir/window-rules.conf"
    hypr_render_paths "$THEMES_SRC/hypr/hyprland.lua.example" "$hypr_dir/hyprland.lua.example" "$cfg_name"
    cp -f "$THEMES_SRC/hypr/window-rules.lua" "$hypr_dir/window-rules.lua.example"
  fi

  run cp -f "$THEMES_SRC/hypr/hypridle.conf" "$hypr_dir/hypridle.conf"
  run cp -f "$THEMES_SRC/hypr/hyprsunset.conf" "$hypr_dir/hyprsunset.conf"
  run cp -f "$THEMES_SRC/hypr/hyprlock.conf" "$hypr_dir/hyprlock.conf"

  if [[ "$active_format" == "lua" ]]; then
    run rm -f "$hypr_dir/hyprland.conf" "$hypr_dir/window-rules.conf"
    if [[ "$dry_run" -eq 0 ]]; then
      if [[ ! -f "$hypr_dir/hyprland.lua" ]]; then
        hypr_render_paths "$THEMES_SRC/hypr/hyprland.lua.example" "$hypr_dir/hyprland.lua" "$cfg_name"
      fi
      if [[ ! -f "$hypr_dir/window-rules.lua" ]]; then
        cp -f "$hypr_dir/window-rules.lua.example" "$hypr_dir/window-rules.lua"
      fi
    else
      printf "[dry-run] formato lua — manter/criar hyprland.lua\n"
    fi
  else
    run rm -f "$hypr_dir/hyprland.lua" "$hypr_dir/window-rules.lua"
  fi

  if [[ $dry_run -eq 0 ]]; then
    sed -i "s#|| hyprlock#|| hyprlock -c $hypr_dir/hyprlock.conf#" "$hypr_dir/hypridle.conf"
    echo "$active_format" >"$hypr_dir/.format"
  fi

  run cp -f "$THEMES_SRC/hypr/scripts/gtkthemes" "$hypr_dir/scripts/gtkthemes"
  run chmod +x "$hypr_dir/scripts/gtkthemes"
  ok "hyprland.conf + hyprland.lua.example (.format=$active_format)"
}
