# Checklist — Hypr-alt (HyprTheme)

```bash
bash check-install.sh   # opção 2
```

## Sessão

| Item | Verificar |
|------|-----------|
| Launcher | `ls -l /usr/bin/run-hyprland-theme` |
| Desktop | `/usr/share/wayland-sessions/hyprland-theme.desktop` |
| Login | SDDM → **HyprTheme** |
| `~/.config/hypr` | **não alterado** |

## Hyprtheme (`~/.config/hyprtheme`)

| Ficheiro | Notas |
|----------|-------|
| `hyprland.conf` | ativo (padrão) |
| `hyprland.lua.example` | opcional |
| `.format` | `conf` ou `lua` |
| `theme.conf` | symlink Matugen |
| `hyprlock.conf` | lock (powermenu detecta sessão) |

## Theme engine

Igual ao full: `~/.config/themes/`

## Recovery

```bash
bash installers/install_themes_matugen.sh --hypr-dir ~/.config/hyprtheme
bash installers/repair-runtime-links.sh
```

## Trocar para lua

```bash
echo lua > ~/.config/hyprtheme/.format
cp ~/.config/hyprtheme/hyprland.lua.example ~/.config/hyprtheme/hyprland.lua
rm -f ~/.config/hyprtheme/hyprland.conf ~/.config/hyprtheme/window-rules.conf
```

Reinicia sessão HyprTheme.
