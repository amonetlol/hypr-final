# Theme Engine

Centralized theme system for Hyprland and related apps.

**Repo layout:** everything lives under `.config/themes/` (clone or symlink this folder to `~/.config/themes`).

## Structure

```
PROJETO-Theme-ROFI/
└── .config/themes/
    ├── scripts/          # theme-apply, theme-selector, action, link-setup, start
    ├── packs/            # 12 theme packs (source of truth)
    ├── waybar/           # config + style (colors.css symlinked per theme)
    ├── rofi/             # scripts + active/ (symlink to current pack)
    ├── foot/ kitty/ alacritty/ mako/ wlogout/ hypr/ starship/
    └── state             # active theme id
```

## Deploy

On your Hyprland machine, from the repo:

```bash
# Creates ~/.config/themes -> repo and ~/.config/hypr/theme.conf
~/.config/themes/scripts/link-setup.sh

# Or from the project before symlink exists:
bash .config/themes/scripts/link-setup.sh

# Preview only
bash .config/themes/scripts/link-setup.sh --dry-run

# Symlinks only, without hyprctl/waybar reload
bash .config/themes/scripts/link-setup.sh --no-apply
```

After **copying or cloning** the repo, run `link-setup.sh` again — it removes broken
`rofi/active` (and other stale copies) and recreates all runtime symlinks.

Manual alternative:

```bash
ln -sfn /path/to/PROJETO-Theme-ROFI/.config/themes ~/.config/themes
ln -sfn ~/.config/themes/hypr/theme.conf ~/.config/hypr/theme.conf
~/.config/themes/scripts/theme-apply.sh --theme catppuccin-mocha
```

## First run

```bash
cd ~/.config/themes/scripts
bash start
# or step by step:
bash generate-packs.sh
bash link-setup.sh
```

## Wallpapers

Add one image per theme to `~/Imagens/wallpapers/`:

```
catppuccin-mocha.jpg
catppuccin-frappe.jpg
tokyonight.jpg
onedark.jpg
monochrome.jpg
everforest.jpg
gruvbox.jpg
kanagawa.jpg
nightfox.jpg
nordic.jpg
nord.jpg
dracula.jpg
```

Theme apply sets the pack wallpaper and symlinks colors for waybar, terminals, mako, wlogout, hypr, rofi, and starship.

`~/.config/starship.toml` is linked to `~/.config/themes/starship/starship.toml` (active pack). Open a new terminal or run a command to see prompt changes after switching theme.

`action.sh --wall` picks any wallpaper without changing theme colors.

## Hyprland binds (suggested)

```ini
bind = SUPER, D, exec, ~/.config/themes/scripts/action.sh --menu
bind = SUPER, V, exec, ~/.config/themes/scripts/action.sh --clip
bind = SUPER, W, exec, ~/.config/themes/scripts/action.sh --wall
bind = SUPER SHIFT, T, exec, ~/.config/themes/scripts/action.sh --wall-matu
bind = SUPER, X, exec, ~/.config/themes/scripts/action.sh --power
bind = SUPER, TAB, exec, ~/.config/themes/scripts/action.sh --window
bind = SUPER, T, exec, ~/.config/themes/scripts/theme-selector.sh
bind = SUPER, RETURN, exec, ~/.config/themes/scripts/action.sh --foot
bind = SUPER SHIFT, C, exec, ~/.config/themes/scripts/configuration.sh
bind = SUPER, F, fullscreen, 0
bind = ALT, TAB, swapnext
# optional — reapply active theme on login
# bind = ..., exec, ~/.config/themes/scripts/theme-apply.sh
```

## Scripts

| Script | Purpose |
|--------|---------|
| `link-setup.sh` | Deploy symlinks to `~/.config` + run theme-apply |
| `start` | chmod → generate-packs → link-setup → hyprctl reload |
| `chmod-scripts.sh` | Make all scripts executable |
| `theme-selector.sh` | Rofi menu → apply global theme + wallpaper |
| `theme-apply.sh` | Symlinks + reload (use `--theme NAME`, `--dry-run`) |
| `action.sh` | Hub: `--menu` `--clip` `--wall` `--wall-matu` `--screen` `--power` … |
| `setup-matugen.sh` | Install matugen + dirs + config + pack matugen |
| `matugen-apply.sh` | Wallpaper → matugen → apply theme `matugen` |
| `configuration.sh` | Open configs in nvim (foot) |
| `generate-packs.sh` | Regenerate all 12 packs from palettes |

## Themes

Dark pastel packs: catppuccin-mocha, catppuccin-frappe, tokyonight, onedark, monochrome, everforest, gruvbox, kanagawa, nightfox, nordic, nord, dracula.

Rofi uses a unified rounded style (based on catppuccin-script.rasi); only layout differs per function.

## Matugen (dynamic theme)

Colors extracted from the wallpaper (Material You). Coexists with the 12 static packs.

```bash
# First time on the Hyprland machine:
bash ~/.config/themes/scripts/setup-matugen.sh

# Apply from an image:
bash ~/.config/themes/scripts/matugen-apply.sh --image ~/Imagens/wallpapers/foto.jpg

# Or SUPER+SHIFT+T → action.sh --wall-matu
# Or theme-selector → "Matugen (dynamic)"
```

`setup-matugen.sh` prints Hyprland `source`, `exec-once` and `bind` lines at the end.

Generated files live in `matugen/generated/` (gitignored). Rofi layouts come from `packs/matugen/`.

## Neovim

Instalado pelo script do projeto (clone direto do repositório):

```bash
bash install/setup-nvim.sh
# ou, manualmente:
git clone https://github.com/amonetlol/nvim ~/.config/nvim
```

Sem integração Matugen/theme engine no editor.

## Hyprland (0.55+ Lua)

Reference config in `hypr/hyprland.lua.example` + `hypr/window-rules.lua`:

```bash
cp ~/.config/themes/hypr/hyprland.lua.example ~/.config/hypr/hyprland.lua
cp ~/.config/themes/hypr/window-rules.lua      ~/.config/hypr/window-rules.lua
ln -sfn ~/.config/themes/hypr/theme.lua        ~/.config/hypr/theme.lua
```

`SUPER+F` → `fullscreen, 1` in Lua: `hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })`

Chained binds (float + center, etc.): use `chain()` helper in the example file.

## Future

- hyprlock per pack
- check-deps.sh
