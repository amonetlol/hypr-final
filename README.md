# Hyprland Theme Engine

Instalação Arch/CachyOS com theme engine (Matugen), waybar, rofi, hyprlock e dois perfis:

| Perfil | Destino | Login |
|--------|---------|-------|
| **Hypr full** | `~/.config/hypr` | SDDM → Hyprland |
| **Hypr-alt** | `~/.config/hyprtheme` | SDDM → HyprTheme |

## Publicar no GitHub (Windows + VMware shared folder)

Os ficheiros saem desta VM/Linux com **LF**. O aviso *LF → CRLF* no GitHub Desktop vem do **Git no Windows** (`core.autocrlf`), não do conteúdo na VM.

Este repo inclui `.gitattributes` para gravar sempre **LF** no GitHub.

No Windows, antes do primeiro commit (só neste repo):

```bash
git add --renormalize .
```

No GitHub Desktop: se ainda aparecer só mudança de line endings num ficheiro, descarta essa alteração ou faz *Discard* na linha vazia — o conteúdo real já está certo.

## Início rápido

```bash
git clone <repo> hypr-theme
cd hypr-theme
bash ensure-executable.sh   # opcional se ./install.sh falhar (git sem +x)
bash install.sh
```

Ou direto:

```bash
bash installers/install_hypr-full.sh   # máquina nova
bash installers/install_hypr-alt.sh    # sessão paralela
```

## Estrutura

```
├── install.sh              menu principal
├── check-install.sh        verificação pós-install
├── shared-themes/          theme engine → ~/.config/themes
├── dotfiles/               bash, .bin, fastfetch (full)
├── dotfiles-alt/session/   run-hyprland-theme + .desktop
├── Assets/                 GTK, ícones, cursor (offline)
└── installers/             scripts de instalação
```

## Config Hyprland

Instala **conf** (ativo) + **lua** como `.example`:

- Padrão: `hyprland.conf` + `.format` = `conf`
- Mudar para lua:

```bash
echo lua > ~/.config/hypr/.format
cp ~/.config/hypr/hyprland.lua.example ~/.config/hypr/hyprland.lua
rm ~/.config/hypr/hyprland.conf ~/.config/hypr/window-rules.conf
hyprctl reload
```

## Atalhos

- **Super+F1** — cheatsheet
- **Super+T** / **Super+Shift+T** — tema / Matugen
- **Super+X** — power menu

Ver `shared-themes/hypr/BINDS.md`.
