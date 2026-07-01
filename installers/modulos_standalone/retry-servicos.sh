#!/usr/bin/env bash
# Verifica systemd units e ativa as que faltam. Instala pacotes necessários se ausentes.

set -euo pipefail

MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$MOD_DIR/../.." && pwd)"
INSTALL_DIR="$REPO_ROOT/installers"
SERVICES_FILE="$MOD_DIR/servicos.txt"

# shellcheck source=../lib/sudo.sh
source "$INSTALL_DIR/lib/sudo.sh"
# shellcheck source=../lib/common.sh
source "$INSTALL_DIR/lib/common.sh"

is_vmware_host() {
  if command -v systemd-detect-virt >/dev/null 2>&1; then
    [[ "$(systemd-detect-virt)" == "vmware" ]] && return 0
  fi
  grep -qi vmware /sys/class/dmi/id/product_name 2>/dev/null && return 0
  return 1
}

unit_enabled() {
  local scope="$1" unit="$2"
  if [[ "$scope" == user ]]; then
    systemctl --user is-enabled "$unit" &>/dev/null
  else
    systemctl is-enabled "$unit" &>/dev/null
  fi
}

enable_unit() {
  local scope="$1" unit="$2" start_now="$3"
  if [[ "$scope" == user ]]; then
    if [[ "$start_now" == yes ]]; then
      systemctl --user enable --now "$unit" 2>/dev/null
    else
      systemctl --user enable "$unit" 2>/dev/null
    fi
  else
    if [[ "$start_now" == yes ]]; then
      sudo systemctl enable --now "$unit" 2>/dev/null
    else
      sudo systemctl enable "$unit" 2>/dev/null
    fi
  fi
}

install_pkgs_if_missing() {
  local pkg
  for pkg in "$@"; do
    [[ -n "$pkg" ]] || continue
    if pacman -Q "$pkg" &>/dev/null; then
      continue
    fi
    log "Instalando dependência do serviço: $pkg"
    sudo pacman -S --needed --noconfirm "$pkg" || warn "pacman falhou: $pkg"
  done
}

log "=== retry-servicos: verificar systemd ==="
rc=0

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line//[[:space:]]/}" ]] && continue
  IFS='|' read -r scope unit pkgs start_now <<<"$line"
  scope="${scope//[[:space:]]/}"
  unit="${unit//[[:space:]]/}"
  start_now="${start_now:-no}"
  start_now="${start_now//[[:space:]]/}"

  if [[ "$unit" == vmtoolsd ]] && ! is_vmware_host; then
    printf "[skip] %s (não é VMware)\n" "$unit"
    continue
  fi

  read -r -a pkg_arr <<<"${pkgs:-}"
  install_pkgs_if_missing "${pkg_arr[@]}"

  if unit_enabled "$scope" "$unit"; then
    printf "[OK]   %s (%s) já enabled\n" "$unit" "$scope"
    continue
  fi

  log "Ativando $unit ($scope, start_now=$start_now)"
  if enable_unit "$scope" "$unit" "$start_now"; then
    ok "enabled: $unit"
  else
    warn "falhou ao ativar: $unit"
    rc=1
  fi
done <"$SERVICES_FILE"

[[ $rc -eq 0 ]] && ok "retry-servicos concluído" || warn "retry-servicos terminou com falhas"
exit "$rc"
