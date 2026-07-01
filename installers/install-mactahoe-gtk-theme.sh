#!/usr/bin/env bash
# MacTahoe GTK theme installer (vendored)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/sudo.sh
source "$SCRIPT_DIR/lib/sudo.sh"

WORKDIR="${TMPDIR:-/tmp}/mactahoe-gtk-$$"
trap 'rm -rf "$WORKDIR"' EXIT
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "=== MacTahoe GTK Theme ==="
sudo pacman -S --needed --noconfirm git sassc glib2 librsvg optipng inkscape imagemagick dialog

if [[ -d MacTahoe-gtk-theme ]]; then
  cd MacTahoe-gtk-theme && git pull
else
  git clone https://github.com/vinceliuice/MacTahoe-gtk-theme.git --depth=1
  cd MacTahoe-gtk-theme
fi

chmod +x install.sh tweaks.sh
./install.sh -c dark -o solid -t default -t blue -t grey -s nord -l -HD --shell -i arch
echo "MacTahoe GTK instalado."
