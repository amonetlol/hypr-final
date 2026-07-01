#!/usr/bin/env bash
# Instala apenas pacotes em falta (pacman + AUR). Ignora os já instalados.

set -euo pipefail

MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$MOD_DIR/../.." && pwd)"
INSTALL_DIR="$REPO_ROOT/installers"
FAILED_LOG="$MOD_DIR/pacotes-falhados.txt"

# shellcheck source=../lib/sudo.sh
source "$INSTALL_DIR/lib/sudo.sh"
# shellcheck source=../lib/common.sh
source "$INSTALL_DIR/lib/common.sh"

read_pkg_list() {
  local file="$1"
  grep -v '^#' "$file" | grep -v '^[[:space:]]*$' || true
}

install_missing_pacman() {
  local -a missing=()
  local pkg
  while IFS= read -r pkg; do
    [[ -n "$pkg" ]] || continue
    if pacman -Q "$pkg" &>/dev/null; then
      printf "[skip] %s (já instalado)\n" "$pkg"
    else
      missing+=("$pkg")
    fi
  done < <(read_pkg_list "$INSTALL_DIR/packages.txt")

  if [[ ${#missing[@]} -eq 0 ]]; then
    ok "Todos os pacotes pacman estão instalados"
    return 0
  fi

  log "Pacman em falta (${#missing[@]}): ${missing[*]}"
  sudo pacman -Sy --noconfirm || warn "pacman -Sy falhou — continuando"

  local -a still_missing=()
  for pkg in "${missing[@]}"; do
    if sudo pacman -S --needed --noconfirm "$pkg"; then
      ok "instalado: $pkg"
    else
      warn "falhou: $pkg"
      still_missing+=("$pkg")
    fi
  done

  if [[ ${#still_missing[@]} -gt 0 ]]; then
    printf '%s\n' "${still_missing[@]}" >"$FAILED_LOG.pacman"
    warn "Pacotes pacman ainda em falta: ${still_missing[*]}"
    warn "Lista: $FAILED_LOG.pacman"
    return 1
  fi
  rm -f "$FAILED_LOG.pacman"
  return 0
}

install_missing_aur() {
  local -a missing=()
  local pkg
  [[ -f "$INSTALL_DIR/packages-aur.txt" ]] || return 0

  if ! command -v yay >/dev/null 2>&1; then
    warn "yay ausente — pulando AUR"
    return 0
  fi

  while IFS= read -r pkg; do
    [[ -n "$pkg" ]] || continue
    if yay -Q "$pkg" &>/dev/null || pacman -Q "$pkg" &>/dev/null; then
      printf "[skip] %s (AUR já instalado)\n" "$pkg"
    else
      missing+=("$pkg")
    fi
  done < <(read_pkg_list "$INSTALL_DIR/packages-aur.txt")

  [[ ${#missing[@]} -gt 0 ]] || { ok "Todos os pacotes AUR estão instalados"; return 0; }

  log "AUR em falta (${#missing[@]}): ${missing[*]}"
  local -a still_missing=()
  local yay_flags=(--needed --noconfirm --answerclean All --answerdiff None --answerupgrade None --removemake)

  for pkg in "${missing[@]}"; do
    if yay -S "${yay_flags[@]}" "$pkg"; then
      ok "AUR instalado: $pkg"
    else
      warn "AUR falhou: $pkg"
      still_missing+=("$pkg")
    fi
  done

  if [[ ${#still_missing[@]} -gt 0 ]]; then
    printf '%s\n' "${still_missing[@]}" >"$FAILED_LOG.aur"
    return 1
  fi
  rm -f "$FAILED_LOG.aur"
  return 0
}

log "=== retry-pacotes: verificar pacotes em falta ==="

# Artefacto conhecido: senha sudo (ex. 156) escrita em pacman.conf via tee + sudo -S
if grep -qE '^[0-9]{1,8}$' /etc/pacman.conf 2>/dev/null; then
  warn "Linhas inválidas em /etc/pacman.conf — removendo artefactos"
  sudo sed -i '/^[0-9]\{1,8\}$/d' /etc/pacman.conf
fi

rc=0
install_missing_pacman || rc=1
install_missing_aur || rc=1
[[ $rc -eq 0 ]] && ok "retry-pacotes concluído" || warn "retry-pacotes terminou com falhas"
exit "$rc"
