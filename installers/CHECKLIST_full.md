# Checklist — Hypr full

```bash
bash check-install.sh   # opção 1
```

## Sistema

| Item | Verificar |
|------|-----------|
| SDDM | `systemctl is-enabled sddm` |
| Sessão Hyprland | Greeter SDDM |
| Tema SDDM | `grep Current /etc/sddm.conf.d/theme.conf` |

## Pacotes

Lista: `installers/packages.txt` + `packages-aur.txt`

```bash
pacman -Q $(grep -v '^#' installers/packages.txt | grep -v '^$')
```

Chave: `hyprland`, `waybar`, `wlogout`, `rofi`, `matugen`, `python-requests`, `xfce-polkit` (AUR)

## Theme engine

| Item | Path |
|------|------|
| Packs | `~/.config/themes/packs/` |
| Estado | `~/.config/themes/state` |
| Rofi active | `readlink ~/.config/themes/rofi/active` |

## Hypr (`~/.config/hypr`)

| Ficheiro | Notas |
|----------|-------|
| `hyprland.conf` | ativo (padrão) |
| `hyprland.lua.example` | opcional |
| `.format` | `conf` ou `lua` |
| `theme.conf` | symlink → pack ativo |
| `hyprlock.conf` | lock screen |

## Dotfiles

`~/.bashrc`, `~/.bin/`, `~/.config/fastfetch/`

## Recovery

```bash
bash installers/repair-runtime-links.sh
bash installers/install_themes_matugen.sh --hypr-dir ~/.config/hypr
bash installers/modulos_standalone/run.sh
```

## Atalhos (manual)

Super+F1, Super+T, Super+Shift+T, Super+X, F12 / Super+F12 waybar
