#!/usr/bin/env bash
# Shared runtime symlink logic (used by link-setup.sh and theme-apply.sh)

# Remove broken symlink, stale copy-as-directory, or plain file blocking a symlink.
prepare_link_target() {
  local dest="$1"
  local dry_run="${2:-0}"

  if [[ -L "$dest" ]]; then
    if [[ ! -e "$dest" ]]; then
      echo "REMOVE broken symlink: $dest"
      [[ "$dry_run" -eq 0 ]] && rm -f "$dest"
    fi
    return 0
  fi

  if [[ -d "$dest" ]]; then
    echo "REMOVE stale directory (expected symlink): $dest"
    [[ "$dry_run" -eq 0 ]] && rm -rf "$dest"
    return 0
  fi

  if [[ -f "$dest" ]]; then
    echo "REMOVE stale file (will symlink): $dest"
    [[ "$dry_run" -eq 0 ]] && rm -f "$dest"
  fi
}

runtime_link() {
  local src="$1" dest="$2" dry_run="${3:-0}"
  local src_real

  src_real="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"
  [[ -e "$src_real" ]] || { echo "ERROR: source missing: $src_real"; return 1; }

  prepare_link_target "$dest" "$dry_run"
  echo "LINK: $dest -> $src_real"

  if [[ "$dry_run" -eq 0 ]]; then
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src_real" "$dest"
  fi
}

# Apply all per-theme runtime symlinks (colors, rofi/active, hypr theme, mako config).
apply_runtime_links() {
  local themes_dir="$1"
  local theme="$2"
  local dry_run="${3:-0}"

  if [[ "$theme" == "matugen" ]]; then
    if declare -f apply_matugen_runtime_links >/dev/null 2>&1; then
      apply_matugen_runtime_links "$themes_dir" "$dry_run"
      return $?
    fi
    echo "ERROR: matugen support not loaded (source lib/matugen.sh)"
    return 1
  fi

  local pack_dir="$themes_dir/packs/$theme"

  [[ -d "$pack_dir" ]] || { echo "ERROR: pack not found: $pack_dir"; return 1; }

  local required=(
    "waybar/colors.css"
    "foot/colors.ini"
    "kitty/colors.conf"
    "alacritty/colors.toml"
    "mako/colors.conf"
    "wlogout/colors.css"
    "hypr/theme.conf"
    "hypr/theme.lua"
    "starship/starship.toml"
    "rofi/shared/colors.rasi"
    "rofi/shared/elements.rasi"
    "rofi/menu.rasi"
    "rofi/launcher.rasi"
  )

  for rel in "${required[@]}"; do
    [[ -f "$pack_dir/$rel" ]] || { echo "ERROR: missing in pack: $rel"; return 1; }
  done

  echo "Runtime links for theme: $theme"

  runtime_link "$pack_dir/waybar/colors.css"     "$themes_dir/waybar/colors.css"     "$dry_run"
  runtime_link "$pack_dir/foot/colors.ini"       "$themes_dir/foot/colors.ini"       "$dry_run"
  runtime_link "$pack_dir/kitty/colors.conf"     "$themes_dir/kitty/colors.conf"     "$dry_run"
  runtime_link "$pack_dir/alacritty/colors.toml" "$themes_dir/alacritty/colors.toml" "$dry_run"
  runtime_link "$pack_dir/mako/colors.conf"      "$themes_dir/mako/colors.conf"      "$dry_run"

  if [[ "$dry_run" -eq 1 ]]; then
    echo "ASSEMBLE: $themes_dir/mako/config"
  else
    cat "$themes_dir/mako/config.base" "$pack_dir/mako/colors.conf" >"$themes_dir/mako/config"
    echo "WROTE: $themes_dir/mako/config"
  fi

  runtime_link "$pack_dir/wlogout/colors.css"       "$themes_dir/wlogout/colors.css"       "$dry_run"
  runtime_link "$pack_dir/hypr/theme.conf"          "$themes_dir/hypr/theme.conf"          "$dry_run"
  runtime_link "$pack_dir/hypr/theme.lua"           "$themes_dir/hypr/theme.lua"           "$dry_run"
  runtime_link "$pack_dir/starship/starship.toml"   "$themes_dir/starship/starship.toml"   "$dry_run"

  # rofi/active -> entire pack rofi/ (menu, launcher, wallpaper, etc.)
  runtime_link "$pack_dir/rofi"        "$themes_dir/rofi/active" "$dry_run"
  runtime_link "$pack_dir/rofi/shared" "$themes_dir/rofi/shared" "$dry_run"

  if [[ "$dry_run" -eq 0 ]]; then
    local active="$themes_dir/rofi/active"
    if [[ -L "$active" && -f "$active/menu.rasi" && -f "$active/shared/colors.rasi" ]]; then
      echo "OK: rofi/active ($(readlink "$active"))"
      echo "OK: rofi/shared/colors.rasi"
    else
      echo "ERROR: rofi/active is invalid after link"
      return 1
    fi
  fi
}
