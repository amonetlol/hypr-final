#!/usr/bin/env bash
# Marca scripts como executáveis no disco e no índice git (antes de push).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

mapfile -t FILES < <(
  find . -type f ! -path './.git/*' \( \
    -name '*.sh' \
    -o -name 'install.sh' \
    -o -name 'check-install.sh' \
    -o -name 'action.sh' \
    -o -name 'gtkthemes' \
    -o -name 'run-hyprland-theme' \
    -o -name 'waybar-wttr.py' \
    -o -path './dotfiles/bin/*' \
  \) ! -name '*.desktop' | sort
)

[[ ${#FILES[@]} -gt 0 ]] || { echo "Nenhum ficheiro encontrado."; exit 1; }

chmod +x "${FILES[@]}"
echo "[OK] chmod +x (${#FILES[@]} ficheiros)"

if [[ -d .git ]]; then
  git add --chmod=+x "${FILES[@]}"
  echo "[OK] git index atualizado (mode 100755)"
  echo "Commit e push para preservar permissões no clone."
else
  echo "[~~] Sem .git — só chmod local. Para GitHub: git add --chmod=+x após init/clone."
fi
