#!/usr/bin/env bash
# Matugen integration helpers for the theme engine.

MATUGEN_THEME_ID="matugen"

matugen_dirs() {
  local themes_dir="$1"
  echo "$themes_dir/matugen"
  echo "$themes_dir/matugen/generated"
  echo "$themes_dir/matugen/templates"
  echo "$themes_dir/packs/matugen"
}

matugen_config_path() {
  local themes_dir="$1"
  echo "$themes_dir/matugen/config.toml"
}

matugen_wallpaper_state() {
  local themes_dir="$1"
  echo "$themes_dir/matugen/wallpaper"
}

ensure_matugen_layout() {
  local themes_dir="$1"
  local base="$themes_dir/matugen/generated"
  mkdir -p \
    "$base/waybar" \
    "$base/hypr" \
    "$base/foot" \
    "$base/kitty" \
    "$base/alacritty" \
    "$base/mako" \
    "$base/wlogout" \
    "$base/starship" \
    "$base/rofi/shared"
}

write_matugen_config() {
  local themes_dir="$1"
  local out="$themes_dir/matugen/config.toml"
  local tpl="$themes_dir/matugen/config.toml.in"
  [[ -f "$tpl" ]] || { echo "ERROR: missing $tpl"; return 1; }
  sed "s|THEMES_DIR|${themes_dir}|g" "$tpl" >"$out"
  echo "WROTE: $out"
}

ensure_matugen_pack() {
  local themes_dir="$1"
  local pack="$themes_dir/packs/matugen"
  local tpl="$themes_dir/scripts/templates/rofi"

  mkdir -p "$pack/rofi/shared"
  cp "$tpl/shared/fonts.rasi" "$pack/rofi/shared/"
  cp "$tpl/shared/elements.rasi" "$pack/rofi/shared/"
  for f in menu launcher window powermenu screenshot clipboard wallpaper confirm; do
    cp "$tpl/${f}.rasi" "$pack/rofi/"
  done

  cat >"$pack/manifest.toml" <<EOF
id = "matugen"
name = "Matugen (dynamic)"
type = "matugen"
wallpaper = ""
accent = "#89b4fa"
EOF
}

matugen_output_ok() {
  local themes_dir="$1"
  local gen="$themes_dir/matugen/generated"
  [[ -f "$gen/waybar/colors.css" && -f "$gen/hypr/theme.conf" && -f "$gen/foot/colors.ini" ]] \
    && [[ -f "$gen/wlogout/colors.css" ]] \
    && [[ -f "$themes_dir/packs/matugen/rofi/shared/colors.rasi" ]]
}

matugen_generated_ok() {
  local themes_dir="$1"
  local state
  state="$(matugen_wallpaper_state "$themes_dir")"
  [[ -f "$state" ]] && matugen_output_ok "$themes_dir"
}

run_matugen() {
  local themes_dir="$1" image="$2"
  local cfg
  cfg="$(matugen_config_path "$themes_dir")"

  command -v matugen >/dev/null 2>&1 || {
    echo "ERROR: matugen not found. Run: bash $themes_dir/scripts/setup-matugen.sh"
    return 1
  }

  [[ -f "$image" ]] || { echo "ERROR: image not found: $image"; return 1; }
  [[ -f "$cfg" ]] || write_matugen_config "$themes_dir"

  ensure_matugen_layout "$themes_dir"
  ensure_matugen_pack "$themes_dir"
  mkdir -p "$themes_dir/packs/matugen/rofi/shared"
  echo "MATUGEN: $image"
  if ! matugen image "$image" -c "$cfg" --mode dark --source-color-index 0; then
    echo "ERROR: matugen failed for $image"
    return 1
  fi

  if ! matugen_output_ok "$themes_dir"; then
    echo "ERROR: matugen output incomplete (check templates)"
    return 1
  fi

  printf '%s\n' "$(readlink -f "$image")" >"$(matugen_wallpaper_state "$themes_dir")"
}

pick_matugen_wallpaper() {
  local themes_dir="$1"
  local wp state
  state="$(matugen_wallpaper_state "$themes_dir")"

  if [[ -f "$state" ]]; then
    wp="$(<"$state")"
    [[ -f "$wp" ]] && { echo "$wp"; return 0; }
  fi

  local dir="$HOME/Imagens/wallpapers"
  [[ -d "$dir" ]] || return 1
  find "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | head -1
}

apply_matugen_runtime_links() {
  local themes_dir="$1"
  local dry_run="${2:-0}"
  local gen="$themes_dir/matugen/generated"
  local pack="$themes_dir/packs/matugen"

  [[ -d "$pack/rofi" ]] || { echo "ERROR: packs/matugen missing — run setup-matugen.sh"; return 1; }
  matugen_generated_ok "$themes_dir" || {
    echo "ERROR: matugen output missing — run matugen-apply.sh with a wallpaper"
    return 1
  }

  echo "Runtime links for theme: matugen (generated)"

  runtime_link "$gen/waybar/colors.css"     "$themes_dir/waybar/colors.css"     "$dry_run"
  runtime_link "$gen/foot/colors.ini"       "$themes_dir/foot/colors.ini"       "$dry_run"
  runtime_link "$gen/kitty/colors.conf"     "$themes_dir/kitty/colors.conf"     "$dry_run"
  runtime_link "$gen/alacritty/colors.toml" "$themes_dir/alacritty/colors.toml" "$dry_run"
  runtime_link "$gen/mako/colors.conf"      "$themes_dir/mako/colors.conf"      "$dry_run"

  if [[ "$dry_run" -eq 1 ]]; then
    echo "ASSEMBLE: $themes_dir/mako/config"
  else
    cat "$themes_dir/mako/config.base" "$gen/mako/colors.conf" >"$themes_dir/mako/config"
    echo "WROTE: $themes_dir/mako/config"
  fi

  runtime_link "$gen/wlogout/colors.css"     "$themes_dir/wlogout/colors.css"     "$dry_run"
  runtime_link "$gen/hypr/theme.conf"        "$themes_dir/hypr/theme.conf"        "$dry_run"
  runtime_link "$gen/hypr/theme.lua"         "$themes_dir/hypr/theme.lua"         "$dry_run"
  runtime_link "$gen/starship/starship.toml" "$themes_dir/starship/starship.toml" "$dry_run"

  # Rofi: layouts + matugen colors live in packs/matugen/rofi/ (same as static packs)
  runtime_link "$pack/rofi"        "$themes_dir/rofi/active" "$dry_run"
  runtime_link "$pack/rofi/shared" "$themes_dir/rofi/shared" "$dry_run"

  if [[ "$dry_run" -eq 0 ]]; then
    local active="$themes_dir/rofi/active"
    if [[ -L "$active" && -f "$active/menu.rasi" && -f "$active/shared/colors.rasi" ]]; then
      echo "OK: rofi/active ($(readlink "$active"))"
      echo "OK: rofi colors from packs/matugen"
    else
      echo "ERROR: rofi/active invalid after matugen link"
      return 1
    fi
  fi
}

reload_themed_apps() {
  hyprctl reload 2>/dev/null || true
  if pgrep -x waybar >/dev/null; then
    pkill -SIGUSR2 waybar 2>/dev/null || { pkill waybar; sleep 0.3; waybar & }
  fi
  makoctl reload 2>/dev/null || true
  pkill -SIGUSR1 kitty 2>/dev/null || true
  pkill -SIGUSR1 foot 2>/dev/null || true
}

print_hyprland_integration() {
  local themes_dir="$1"
  cat <<EOF

╔══════════════════════════════════════════════════════════════════╗
║  Hyprland — adicione em ~/.config/hypr/hyprland.conf (ou .lua)   ║
╚══════════════════════════════════════════════════════════════════╝

# --- Tema (symlink criado pelo install em ~/.config/hypr/theme.conf) ---
source = ~/.config/hypr/theme.conf
# ou, se usar hyprland.lua:
# local theme = require("theme")   # ~/.config/hypr/theme.lua → themes/hypr/theme.lua

# --- exec-once (sessão) ---
exec-once = waybar -c $themes_dir/waybar/config.jsonc -s $themes_dir/waybar/style.css
exec-once = mako -c $themes_dir/mako/config

# --- Binds sugeridos ---
bind = SUPER, D, exec, $themes_dir/scripts/action.sh --menu
bind = SUPER, V, exec, $themes_dir/scripts/action.sh --clip
bind = SUPER, W, exec, $themes_dir/scripts/action.sh --wall
bind = SUPER SHIFT, T, exec, $themes_dir/scripts/action.sh --wall-matu
bind = SUPER, X, exec, $themes_dir/scripts/action.sh --power
bind = SUPER, TAB, exec, $themes_dir/scripts/action.sh --window
bind = SUPER, T, exec, $themes_dir/scripts/theme-selector.sh
bind = SUPER, RETURN, exec, $themes_dir/scripts/action.sh --foot
bind = SUPER SHIFT, C, exec, $themes_dir/scripts/configuration.sh
bind = SUPER, F, fullscreen, 0
bind = ALT, TAB, swapnext

# --- Matugen: reaplicar cores do wallpaper atual no login (opcional) ---
# exec-once = $themes_dir/scripts/matugen-apply.sh --from-state

# Starship (se ainda não tiver no .bashrc/.zshrc):
# eval "\$(starship init bash)"
# export STARSHIP_CONFIG=$themes_dir/starship/starship.toml

EOF
}
