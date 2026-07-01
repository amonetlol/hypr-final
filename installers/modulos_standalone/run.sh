#!/usr/bin/env bash
# Pós-verificação: pacotes + serviços + hide-shortcuts.

set -euo pipefail

MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS_DIR="$(cd "$MOD_DIR/.." && pwd)"

log() { printf "\n[*] %s\n" "$1"; }

log "Módulos pós-instalação"
bash "$MOD_DIR/retry-pacotes.sh" || true
bash "$MOD_DIR/retry-servicos.sh" || true
bash "$INSTALLERS_DIR/hide-shortcuts.sh" || true
log "modulos_standalone concluído"
