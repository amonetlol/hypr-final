# Guia de instalação

## 1. Escolher perfil

```bash
bash install.sh
```

| Opção | Script | Quando usar |
|-------|--------|-------------|
| **1 — Hypr full** | `installers/install_hypr-full.sh` | Máquina nova, SDDM, dotfiles, `~/.config/hypr` |
| **2 — Hypr-alt** | `installers/install_hypr-alt.sh` | Já tens Hypr em `~/.config/hypr`; sessão **HyprTheme** separada |

## 2. Pré-requisitos

- Arch Linux ou CachyOS
- Utilizador com sudo
- `Assets/` com zip/tar.xz (GTK, MacTahoe, Qogir) — ver `Assets/README.md`
- Internet (pacman, AUR, wall2)

## 3. Pós-instalação

```bash
bash check-install.sh
```

Reinicia e entra na sessão correta no SDDM.

### Full

- Sessão: **Hyprland**
- Config: `~/.config/hypr/hyprland.conf`
- Wallpapers: `~/Imagens/wallpapers/`

### Alt

- Sessão: **HyprTheme**
- Config: `~/.config/hyprtheme/hyprland.conf`
- `~/.config/hypr` **não é alterado**

## 4. Recovery (sem reinstalar tudo)

| Script | Função |
|--------|--------|
| `installers/setup_inicial_themes.sh` | Recopia `shared-themes` → `~/.config/themes`, symlinks runtime |
| `installers/install_themes_matugen.sh` | Matugen + hypr configs + aplica pack |
| `installers/repair-runtime-links.sh` | Repara symlinks rofi/waybar/foot |
| `installers/modulos_standalone/retry-pacotes.sh` | Pacotes em falta |
| `installers/modulos_standalone/retry-servicos.sh` | Serviços systemd |
| `installers/hide-shortcuts.sh` | Atalhos desktop Thunar |
| `installers/chaotic-aur.sh` | Chaotic-AUR (opcional) |

### Matugen / temas

`setup_inicial_themes` e `install_themes_matugen` são chamados no install full e alt.

Usa-os separados quando:

- `~/.config/themes` corrompeu ou symlinks quebrados
- Precisas regenerar packs ou mudar tema base
- Recovery após clone manual do repo

**Full:**

```bash
bash installers/install_themes_matugen.sh --hypr-dir ~/.config/hypr
```

**Alt:**

```bash
bash installers/install_themes_matugen.sh --hypr-dir ~/.config/hyprtheme
```

## 5. Trocar conf ↔ lua

Ficheiro `.format` em `~/.config/hypr` ou `~/.config/hyprtheme`:

```bash
# ativar lua
echo lua > ~/.config/hypr/.format
cp ~/.config/hypr/hyprland.lua.example ~/.config/hypr/hyprland.lua
rm -f ~/.config/hypr/hyprland.conf ~/.config/hypr/window-rules.conf
hyprctl reload
```

## 6. Log

Install full grava: `install.log` na raiz do repo clonado.

## 7. Checklists

- `installers/CHECKLIST_full.md`
- `installers/CHECKLIST_alt.md`
