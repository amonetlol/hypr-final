#!/usr/bin/env bash
# open-vm-tools when running inside VMware

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/sudo.sh
source "$SCRIPT_DIR/lib/sudo.sh"

warn() { printf "[AVISO] %s\n" "$1"; }

is_vmware() {
  if command -v systemd-detect-virt >/dev/null 2>&1; then
    [[ "$(systemd-detect-virt)" == "vmware" ]] && return 0
  fi
  grep -qi vmware /sys/class/dmi/id/product_name 2>/dev/null && return 0
  grep -qi vmware /sys/class/dmi/id/sys_vendor 2>/dev/null && return 0
  return 1
}

if ! is_vmware; then
  echo "Não é VMware — open-vm-tools ignorado."
  exit 0
fi

echo "VMware detectado — instalando open-vm-tools..."
if ! sudo pacman -S --needed --noconfirm open-vm-tools gtkmm3 fuse2 fuse3; then
  warn "open-vm-tools falhou (mirrors?) — continuando sem vmtoolsd"
  exit 0
fi
sudo systemctl enable --now vmtoolsd || warn "vmtoolsd não ativado"
echo "vmtoolsd configurado."
