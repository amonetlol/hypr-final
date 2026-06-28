#!/usr/bin/env bash
# Deploy theme engine: symlink repo into ~/.config and wire Hyprland.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_SRC="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/runtime-links.sh
source "$SCRIPT_DIR/lib/runtime-links.sh"

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
THEMES_DEST="$CONFIG_HOME/themes"
HYPR_DIR="$CONFIG_HOME/hypr"
WLOGOUT_DEST="$CONFIG_HOME/wlogout"

DRY_RUN=0
APPLY_THEME=1
THEME=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Deploy symlinks for the theme engine on this machine.

  ~/.config/themes              ->  <repo>/.config/themes
  ~/.config/wlogout               ->  ~/.config/themes/wlogout
  ~/.config/hypr/theme.conf       ->  ~/.config/themes/hypr/theme.conf
  ~/.config/hypr/theme.lua        ->  ~/.config/themes/hypr/theme.lua
  ~/.config/starship.toml         ->  ~/.config/themes/starship/starship.toml

Runtime symlinks (always repaired — safe after copy/git clone):
  rofi/active                   ->  packs/<theme>/rofi/
  waybar/colors.css, foot, kitty, alacritty, mako, wlogout, hypr, starship

Also: chmod +x on all .sh scripts, wlogout icons fetch.

Options:
  --dry-run          Show actions without changing anything
  --no-apply         Skip theme-apply reload/wallpaper (runtime links still run)
  --theme NAME       Theme for runtime links (default: state or catppuccin-mocha)
  -h, --help         Show this help
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --no-apply) APPLY_THEME=0; shift ;;
    --theme) THEME="$2"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1"; usage 1 ;;
  esac
done

link_path() {
  local src="$1" dest="$2"
  local src_real dest_parent

  src_real="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -L "$dest" ]]; then
      local current
      current="$(readlink -f "$dest" 2>/dev/null || readlink "$dest")"
      if [[ "$current" == "$src_real" ]]; then
        echo "OK (exists): $dest -> $src_real"
        return 0
      fi
      prepare_link_target "$dest" "$DRY_RUN"
    elif [[ -d "$dest" ]]; then
      prepare_link_target "$dest" "$DRY_RUN"
    else
      prepare_link_target "$dest" "$DRY_RUN"
    fi
  else
    echo "LINK: $dest -> $src_real"
  fi

  if [[ $DRY_RUN -eq 0 ]]; then
    dest_parent="$(dirname "$dest")"
    mkdir -p "$dest_parent"
    ln -sfn "$src_real" "$dest"
  fi
}

resolve_themes_dest() {
  if [[ -d "$THEMES_DEST/packs" ]]; then
    readlink -f "$THEMES_DEST" 2>/dev/null || echo "$THEMES_DEST"
  elif [[ -L "$THEMES_DEST" ]]; then
    readlink -f "$THEMES_DEST" 2>/dev/null || echo "$THEMES_SRC"
  elif [[ -d "$THEMES_SRC/packs" ]]; then
    echo "$THEMES_SRC"
  else
    echo "$THEMES_DEST"
  fi
}

resolve_theme() {
  local themes_dir="$1"
  if [[ -n "$THEME" ]]; then
    echo "$THEME"
    return
  fi
  if [[ -f "$themes_dir/state" ]]; then
    tr -d '[:space:]' <"$themes_dir/state"
    return
  fi
  echo "catppuccin-mocha"
}

chmod_scripts() {
  echo "=== chmod +x on bash scripts ==="
  if [[ $DRY_RUN -eq 1 ]]; then
    bash "$SCRIPT_DIR/chmod-scripts.sh" 2>/dev/null | sed 's/^chmod +x /chmod +x /' || find "$THEMES_SRC/scripts" "$THEMES_SRC/rofi/scripts" -type f -print
    return
  fi
  bash "$SCRIPT_DIR/chmod-scripts.sh"
}

setup_wlogout_icons() {
  echo "=== Wlogout icons ==="
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "RUN: $SCRIPT_DIR/setup-wlogout-icons.sh $THEMES_SRC/wlogout/icons"
    return
  fi
  bash "$SCRIPT_DIR/setup-wlogout-icons.sh" "$THEMES_SRC/wlogout/icons" || true
}

setup_cliphist() {
  echo "=== Cliphist database ==="
  if ! command -v cliphist &>/dev/null; then
    echo "SKIP: cliphist not installed"
    return
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "INIT: cliphist store (if empty)"
    return
  fi
  if ! cliphist list &>/dev/null || [[ -z "$(cliphist list 2>/dev/null | head -1)" ]]; then
    printf 'theme-engine-init' | cliphist store 2>/dev/null || true
    echo "Initialized cliphist database"
  else
    echo "OK: cliphist database exists"
  fi
}

echo "Theme engine deploy"
echo "  Source: $THEMES_SRC"
echo "  Target: $THEMES_DEST"
echo

chmod_scripts

if [[ "$(readlink -f "$THEMES_SRC")" == "$(readlink -f "$THEMES_DEST" 2>/dev/null || true)" ]]; then
  echo "Already deployed at $THEMES_DEST"
elif [[ -d "$THEMES_DEST" && ! -L "$THEMES_DEST" ]]; then
  echo "ERROR: $THEMES_DEST is a directory. Backup and remove it first:"
  echo "  mv $THEMES_DEST ${THEMES_DEST}.bak"
  echo "  bash $SCRIPT_DIR/link-setup.sh"
  exit 1
else
  link_path "$THEMES_SRC" "$THEMES_DEST"
fi

THEMES_ACTIVE="$(resolve_themes_dest)"
THEME="$(resolve_theme "$THEMES_ACTIVE")"

setup_wlogout_icons

echo
setup_cliphist

echo
echo "=== Runtime symlinks (rofi/active + colors) ==="
apply_runtime_links "$THEMES_ACTIVE" "$THEME" "$DRY_RUN"

if [[ $DRY_RUN -eq 0 ]]; then
  echo "$THEME" >"$THEMES_ACTIVE/state"
fi

echo
echo "=== Wlogout ==="
link_path "$THEMES_ACTIVE/wlogout" "$WLOGOUT_DEST"

echo
echo "=== Hyprland ==="
mkdir -p "$HYPR_DIR" 2>/dev/null || true
if [[ -d "$HYPR_DIR" ]]; then
  link_path "$THEMES_ACTIVE/hypr/theme.conf" "$HYPR_DIR/theme.conf"
  link_path "$THEMES_ACTIVE/hypr/theme.lua" "$HYPR_DIR/theme.lua"
else
  echo "SKIP: $HYPR_DIR not found (create ~/.config/hypr first)"
fi

echo
echo "=== Starship ==="
link_path "$THEMES_ACTIVE/starship/starship.toml" "$CONFIG_HOME/starship.toml"

echo
if [[ $APPLY_THEME -eq 1 ]]; then
  echo "=== theme-apply (reload + wallpaper) ==="
  apply_args=(--theme "$THEME")
  [[ $DRY_RUN -eq 1 ]] && apply_args+=(--dry-run)
  bash "$THEMES_ACTIVE/scripts/theme-apply.sh" "${apply_args[@]}"
else
  echo "Skipped theme-apply reload (--no-apply)"
fi

echo
if [[ $DRY_RUN -eq 0 ]]; then
  echo "=== hyprctl reload ==="
  hyprctl reload 2>/dev/null || echo "WARN: hyprctl not available"
fi

echo
echo "Done."
if [[ $DRY_RUN -eq 0 ]]; then
  cat <<EOF

Runtime paths ready:
  rofi/active -> $(readlink "$THEMES_ACTIVE/rofi/active" 2>/dev/null || echo "?")

Hyprland — add ONE of these to hyprland.conf:
  source = ~/.config/hypr/theme.conf
  source = ~/.config/hypr/theme.lua

Next steps:
  1. Wallpapers in ~/Imagens/wallpapers/ (optional)
  2. ~/.config/themes/scripts/theme-apply.sh   (with wallpaper when ready)

EOF
fi
