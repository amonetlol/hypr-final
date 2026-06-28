#!/usr/bin/env bash
# Install Matugen, create directories, deploy config and matugen pack.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# shellcheck source=lib/matugen.sh
source "$SCRIPT_DIR/lib/matugen.sh"

DRY_RUN=0
SKIP_INSTALL=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Install Matugen integration for the theme engine.

Options:
  --dry-run        Show actions only
  --skip-install   Skip package install (dirs + config only)
  -h, --help       Show help
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --skip-install) SKIP_INSTALL=1; shift ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1"; usage 1 ;;
  esac
done

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    echo "[*] $*"
    "$@"
  fi
}

install_packages() {
  echo "=== Packages ==="
  if [[ $SKIP_INSTALL -eq 1 ]]; then
    echo "SKIP: --skip-install"
    return 0
  fi

  if command -v matugen >/dev/null 2>&1; then
    echo "OK: matugen $(matugen --version 2>/dev/null | head -1 || true)"
  elif command -v pacman >/dev/null 2>&1; then
    echo "Installing via pacman (may need AUR helper for matugen)..."
    if [[ $DRY_RUN -eq 0 ]]; then
      sudo pacman -S --needed matugen 2>/dev/null \
        || sudo pacman -S --needed matugen-bin 2>/dev/null \
        || {
          echo "WARN: matugen not in repos. Install manually:"
          echo "  cargo install matugen"
          echo "  paru -S matugen-bin"
        }
    fi
  else
    echo "Install matugen manually: https://github.com/InioX/matugen"
  fi

  if command -v awww >/dev/null 2>&1; then
    echo "OK: awww (wallpaper)"
  elif command -v pacman >/dev/null 2>&1 && [[ $DRY_RUN -eq 0 ]]; then
    echo "Installing awww (wallpaper)..."
    sudo pacman -S --needed awww 2>/dev/null || echo "WARN: install awww manually (AUR)"
  else
    echo "WARN: awww not found — install for wallpaper support"
  fi
}

setup_dirs() {
  echo
  echo "=== Directories ==="
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] mkdir matugen/generated/*"
  else
    ensure_matugen_layout "$THEMES_DIR"
    echo "OK: $THEMES_DIR/matugen/generated/"
  fi
}

deploy_config() {
  echo
  echo "=== Matugen config ==="
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] write $THEMES_DIR/matugen/config.toml"
    echo "[dry-run] optional link $CONFIG_HOME/matugen/config.toml"
  else
    write_matugen_config "$THEMES_DIR"
    if mkdir -p "$CONFIG_HOME/matugen" 2>/dev/null; then
      ln -sfn "$THEMES_DIR/matugen/config.toml" "$CONFIG_HOME/matugen/config.toml"
      echo "LINK: $CONFIG_HOME/matugen/config.toml -> themes/matugen/config.toml"
    else
      echo "SKIP: cannot write $CONFIG_HOME/matugen (OK — scripts use --config explicitly)"
    fi
  fi
}

setup_pack() {
  echo
  echo "=== Pack matugen ==="
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] ensure packs/matugen (rofi layouts)"
  else
    ensure_matugen_pack "$THEMES_DIR"
  fi
}

chmod_scripts() {
  echo
  echo "=== chmod scripts ==="
  run bash "$SCRIPT_DIR/chmod-scripts.sh"
}

echo "Matugen setup — Theme Engine"
echo "  Themes: $THEMES_DIR"
echo

install_packages
setup_dirs
deploy_config
setup_pack
chmod_scripts

echo
echo "=== Done ==="
echo
echo "Next steps:"
echo "  1. bash $SCRIPT_DIR/matugen-apply.sh --image ~/Imagens/wallpapers/sua-imagem.jpg"
echo "  2. Or: SUPER+SHIFT+T  →  action.sh --wall-matu  (after Hyprland binds)"
echo "  3. Or: theme-selector.sh  →  Matugen (dynamic)"
echo

print_hyprland_integration "$THEMES_DIR"
