#!/usr/bin/env bash
# Generate all theme packs from palette definitions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$(dirname "$SCRIPT_DIR")"
PACKS_DIR="$THEMES_DIR/packs"
TEMPLATES="$SCRIPT_DIR/templates/rofi"

# id|display_name|bg|bg_alt|bg_mantle|fg|muted|accent|active|urgent|red|green|yellow|blue|magenta|cyan
PALETTES=(
  "catppuccin-mocha|Catppuccin Mocha|1e1e2e|313244|181825|cdd6f4|6c7086|89b4fa|a6e3a1|f38ba8|f38ba8|a6e3a1|f9e2af|89b4fa|cba6f7|94e2d5"
  "catppuccin-frappe|Catppuccin Frappe|303446|414559|292c3c|c6d0f5|737994|8caaee|a6d189|e78284|e78284|a6d189|e5c890|8caaee|ca9ee6|99d1db"
  "tokyonight|Tokyo Night|1a1b26|24283b|16161e|c0caf5|565f89|7aa2f7|9ece6a|f7768e|f7768e|9ece6a|e0af68|7aa2f7|bb9af7|7dcfff"
  "onedark|One Dark|282c34|2c323c|21252b|abb2bf|5c6370|61afef|98c379|e06c75|e06c75|98c379|e5c07b|61afef|c678dd|56b6c2"
  "monochrome|Monochrome|1e1e1e|2d2d2d|151515|d4d4d4|6e6e6e|9e9e9e|b0b0b0|c75050|c75050|8a8a8a|a0a0a0|888888|999999|aaaaaa"
  "everforest|Everforest|2d353b|3d484d|232a2e|d3c6aa|859289|7fbbb3|a7c080|e67e80|e67e80|a7c080|dbbc7f|7fbbb3|d699b6|83c092"
  "gruvbox|Gruvbox|282828|3c3836|1d2021|ebdbb2|928374|83a598|b8bb26|fb4934|fb4934|b8bb26|fabd2f|83a598|d3869b|8ec07c"
  "kanagawa|Kanagawa|1f1f28|2a2a37|16161d|dcd7ba|727169|7e9cd8|98bb6c|c34043|c34043|98bb6c|c0a36e|7e9cd8|957fb8|7aa89f"
  "nightfox|Nightfox|192330|212f3b|121922|cdcecf|71839b|719cd6|81b29a|c94f6d|c94f6d|81b29a|e3c78a|719cd6|ad8ee6|70a5b2"
  "nordic|Nordic|2e3440|3b4252|242933|eceff4|616e88|88c0d0|a3be8c|bf616a|bf616a|a3be8c|ebcb8b|88c0d0|b48ead|8fbcbb"
  "nord|Nord|2e3440|434c5e|272c36|e5e9f0|4c566a|81a1c1|a3be8c|bf616a|bf616a|a3be8c|ebcb8b|81a1c1|b48ead|88c0d0"
  "dracula|Dracula|282a36|343746|21222c|f8f8f2|6272a4|bd93f9|50fa7b|ff5555|ff5555|50fa7b|f1fa8c|bd93f9|ff79c6|8be9fd"
)

write_colors_rasi() {
  local dir="$1" bg="$2" bg_alt="$3" fg="$4" muted="$5" accent="$6" active="$7" urgent="$8"
  cat >"$dir/rofi/shared/colors.rasi" <<EOF
* {
    background:     #${bg}FF;
    background-alt: #${bg_alt}FF;
    foreground:     #${fg}FF;
    muted:          #${muted}FF;
    accent:         #${accent}FF;
    active:         #${active}FF;
    urgent:         #${urgent}FF;
    selected:       #${accent}FF;
}
EOF
}

write_waybar_colors() {
  local dir="$1" bg="$2" bg_alt="$3" bg_mantle="$4" fg="$5" muted="$6" accent="$7" active="$8" urgent="$9"
  cat >"$dir/waybar/colors.css" <<EOF
@define-color bg #${bg_alt};

@define-color workspace-button-bg #${bg_mantle};
@define-color workspace-button-fg #${muted};
@define-color workspace-button-hover-bg #${accent};
@define-color workspace-button-hover-fg #${fg};
@define-color workspace-button-active-bg #${accent};
@define-color workspace-button-active-fg #${fg};

@define-color audio-fg #${accent};
@define-color audio-muted-fg #${urgent};

@define-color mpris-fg #${fg};
@define-color mpris-fg-paused #${muted};

@define-color brightness-fg #${active};

@define-color battery-fg #${active};
@define-color battery-fg-warning #${active};
@define-color battery-fg-critical #${urgent};

@define-color updates-fg #${accent};

@define-color clock-fg #${accent};

@define-color cpu-fg #${active};

@define-color swaync-fg #${active};

@define-color network-fg #${accent};

@define-color arch-logo #${fg};

@define-color weather-text #${muted};

@define-color wlogout-fg #${muted};

@define-color tooltip-bg #${bg_mantle};
@define-color tooltip-fg #${fg};
@define-color tooltip-border #${accent};

@define-color wp-changer-fg #${muted};
EOF
}

write_foot_colors() {
  local dir="$1" bg="$2" fg="$3" red="$4" green="$5" yellow="$6" blue="$7" magenta="$8" cyan="$9" bg_alt="${10}"
  cat >"$dir/foot/colors.ini" <<EOF
[colors-dark]
alpha=1.0
foreground=${fg}
background=${bg}

regular0=${bg}
regular1=${red}
regular2=${green}
regular3=${yellow}
regular4=${blue}
regular5=${magenta}
regular6=${cyan}
regular7=${fg}

bright0=${bg_alt}
bright1=${red}
bright2=${green}
bright3=${yellow}
bright4=${blue}
bright5=${magenta}
bright6=${cyan}
bright7=${fg}
EOF
}

write_kitty_colors() {
  local dir="$1" bg="$2" fg="$3" red="$4" green="$5" yellow="$6" blue="$7" magenta="$8" cyan="$9" bg_alt="${10}"
  cat >"$dir/kitty/colors.conf" <<EOF
background #${bg}
foreground #${fg}
selection_background #${fg}
selection_foreground #${bg}
cursor #${fg}

color0 #${bg}
color8 #${bg_alt}
color1 #${red}
color9 #${red}
color2 #${green}
color10 #${green}
color3 #${yellow}
color11 #${yellow}
color4 #${blue}
color12 #${blue}
color5 #${magenta}
color13 #${magenta}
color6 #${cyan}
color14 #${cyan}
color7 #${fg}
color15 #${fg}
EOF
}

write_alacritty_colors() {
  local dir="$1" bg="$2" fg="$3" red="$4" green="$5" yellow="$6" blue="$7" magenta="$8" cyan="$9" bg_alt="${10}"
  cat >"$dir/alacritty/colors.toml" <<EOF
[colors.primary]
background = "#${bg}"
foreground = "#${fg}"

[colors.normal]
black   = "#${bg}"
red     = "#${red}"
green   = "#${green}"
yellow  = "#${yellow}"
blue    = "#${blue}"
magenta = "#${magenta}"
cyan    = "#${cyan}"
white   = "#${fg}"

[colors.bright]
black   = "#${bg_alt}"
red     = "#${red}"
green   = "#${green}"
yellow  = "#${yellow}"
blue    = "#${blue}"
magenta = "#${magenta}"
cyan    = "#${cyan}"
white   = "#${fg}"
EOF
}

write_mako_colors() {
  local dir="$1" bg="$2" fg="$3" bg_alt="$4" accent="$5" urgent="$6"
  cat >"$dir/mako/colors.conf" <<EOF
background-color=#${bg}
text-color=#${fg}
border-color=#${bg_alt}
progress-color=over #${accent}

[urgency=low]
border-color=#${bg_alt}

[urgency=normal]
border-color=#${bg_alt}

[urgency=high]
border-color=#${urgent}
text-color=#${urgent}
EOF
}

write_starship_config() {
  local dir="$1" bar1="$2" accent="$3" bg="$4" bg_alt="$5" bg_mantle="$6" fg="$7" muted="$8"
  mkdir -p "$dir/starship"
  cat >"$dir/starship/starship.toml" <<EOF
format = """
[░▒▓](#${bar1})\\
[  ](bg:#${bar1} fg:#${bg})\\
[](bg:#${accent} fg:#${bar1})\\
\$directory\\
[](fg:#${accent} bg:#${bg_alt})\\
\$git_branch\\
\$git_status\\
[](fg:#${bg_alt} bg:#${bg_mantle})\\
\$nodejs\\
\$rust\\
\$golang\\
\$php\\
[](fg:#${bg_mantle} bg:#${bg})\\
\$time\\
[ ](fg:#${bg})\\
\$character"""

scan_timeout = 200
command_timeout = 5000

[directory]
style = "fg:#${fg} bg:#${accent}"
format = "[ \$path ](\$style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = " "
"Downloads" = " "
"Music" = " "
"Pictures" = " "
"Desktop" = " "
"~" = " "
"CPP" = " "
"Cpp" = " "
"C++" = " "
"c++" = " "
"cpp" = " "

[git_branch]
symbol = ""
style = "bg:#${bg_alt}"
format = '[[ \$symbol \$branch ](fg:#${accent} bg:#${bg_alt})](\$style)'

[git_status]
style = "bg:#${bg_alt}"
format = '[[(\$all_status\$ahead_behind )](fg:#${accent} bg:#${bg_alt})](\$style)'

[nodejs]
symbol = ""
style = "bg:#${bg_mantle}"
format = '[[ \$symbol (\$version) ](fg:#${accent} bg:#${bg_mantle})](\$style)'

[rust]
symbol = ""
style = "bg:#${bg_mantle}"
format = '[[ \$symbol (\$version) ](fg:#${accent} bg:#${bg_mantle})](\$style)'

[golang]
symbol = "ﳑ"
style = "bg:#${bg_mantle}"
format = '[[ \$symbol (\$version) ](fg:#${accent} bg:#${bg_mantle})](\$style)'

[php]
symbol = ""
style = "bg:#${bg_mantle}"
format = '[[ \$symbol (\$version) ](fg:#${accent} bg:#${bg_mantle})](\$style)'

[time]
disabled = true
time_format = "%R"
style = "bg:#${bg}"
format = '[[  \$time ](fg:#${muted} bg:#${bg})](\$style)'
EOF
}

write_wlogout_colors() {
  local dir="$1" bg="$2" fg="$3" bg_alt="$4" accent="$5"
  cat >"$dir/wlogout/colors.css" <<EOF
@define-color window-bg rgba($(hex_to_rgb "$bg"), 0.92);
@define-color button-bg rgba($(hex_to_rgb "$bg_alt"), 0.75);
@define-color button-fg #${fg};
@define-color button-border #${bg};
@define-color button-hover #${accent};
@define-color button-fg-hover #${bg};
EOF
}

hex_to_rgb() {
  local h="$1"
  printf "%d, %d, %d" "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

# Hyprland color: 0xAARRGGBB
hypr_color() {
  local hex="$1" alpha="$2"
  echo "0x${alpha}${hex}"
}

write_hypr_theme() {
  local dir="$1" bg="$2" accent="$3" active="$4" urgent="$5" bg_alt="$6"
  local ab ac au bi bs ba bu

  ab="$(hypr_color "$accent" ee)"
  ac="$(hypr_color "$active" ee)"
  au="$(hypr_color "$urgent" ee)"
  bi="$(hypr_color "$bg_alt" aa)"
  bs="$(hypr_color "$bg" ee)"
  ba="$(hypr_color "$accent" ee)"
  bu="$(hypr_color "$urgent" ee)"

  cat >"$dir/hypr/theme.conf" <<EOF
# Theme colors — sourced from theme engine

general {
    col.active_border = ${ab} ${ac} 45deg
    col.inactive_border = ${bi}
}

decoration {
    rounding = 10
    active_opacity = 1.0
    inactive_opacity = 0.92

    shadow {
        enabled = true
        range = 12
        render_power = 3
        color = ${bs}
    }

    blur {
        enabled = true
        size = 6
        passes = 2
        new_optimizations = true
    }
}

group {
    col.border_active = ${ba}
    col.border_inactive = ${bi}
    col.border_locked_active = ${bu}
    col.border_locked_inactive = ${bi}
}
EOF

  cat >"$dir/hypr/theme.lua" <<EOF
-- Theme colors — sourced from theme engine (Hyprland Lua config)

local M = {}

M.general = {
    ["col.active_border"] = {
        colors = { "${ab}", "${ac}" },
        angle = 45,
    },
    ["col.inactive_border"] = ${bi},
}

M.decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
        enabled = true,
        range = 12,
        render_power = 3,
        color = ${bs},
    },
    blur = {
        enabled = true,
        size = 6,
        passes = 2,
        new_optimizations = true,
    },
}

M.group = {
    ["col.border_active"] = ${ba},
    ["col.border_inactive"] = ${bi},
    ["col.border_locked_active"] = ${bu},
    ["col.border_locked_inactive"] = ${bi},
}

return M
EOF
}

write_manifest() {
  local dir="$1" id="$2" name="$3"
  cat >"$dir/manifest.toml" <<EOF
id = "${id}"
name = "${name}"
wallpaper = "~/Imagens/wallpapers/${id}.jpg"
accent = "#${4}"
EOF
}

copy_rofi_templates() {
  local dir="$1"
  mkdir -p "$dir/rofi/shared"
  cp "$TEMPLATES/shared/fonts.rasi" "$dir/rofi/shared/"
  cp "$TEMPLATES/shared/elements.rasi" "$dir/rofi/shared/"
  for f in menu launcher window powermenu screenshot clipboard wallpaper confirm; do
    cp "$TEMPLATES/${f}.rasi" "$dir/rofi/${f}.rasi"
  done
}

for entry in "${PALETTES[@]}"; do
  IFS='|' read -r id name bg bg_alt bg_mantle fg muted accent active urgent red green yellow blue magenta cyan <<<"$entry"

  pack="$PACKS_DIR/$id"
  mkdir -p "$pack"/{waybar,foot,kitty,alacritty,mako,wlogout,hypr,starship,rofi/shared}

  write_manifest "$pack" "$id" "$name" "$accent"
  write_colors_rasi "$pack" "$bg" "$bg_alt" "$fg" "$muted" "$accent" "$active" "$urgent"
  write_waybar_colors "$pack" "$bg" "$bg_alt" "$bg_mantle" "$fg" "$muted" "$accent" "$active" "$urgent"
  write_foot_colors "$pack" "$bg" "$fg" "$red" "$green" "$yellow" "$blue" "$magenta" "$cyan" "$bg_alt"
  write_kitty_colors "$pack" "$bg" "$fg" "$red" "$green" "$yellow" "$blue" "$magenta" "$cyan" "$bg_alt"
  write_alacritty_colors "$pack" "$bg" "$fg" "$red" "$green" "$yellow" "$blue" "$magenta" "$cyan" "$bg_alt"
  write_mako_colors "$pack" "$bg" "$fg" "$bg_alt" "$accent" "$urgent"
  write_wlogout_colors "$pack" "$bg" "$fg" "$bg_alt" "$accent"
  write_starship_config "$pack" "$cyan" "$accent" "$bg" "$bg_alt" "$bg_mantle" "$fg" "$muted"
  write_hypr_theme "$pack" "$bg" "$accent" "$active" "$urgent" "$bg_alt"
  copy_rofi_templates "$pack"

  echo "Generated: $id"
done

echo "Done. ${#PALETTES[@]} theme packs in $PACKS_DIR"

MATUGEN_PACK="$PACKS_DIR/matugen"
if [[ -f "$MATUGEN_PACK/manifest.toml" ]]; then
  copy_rofi_templates "$MATUGEN_PACK"
  echo "Refreshed rofi layouts: matugen"
fi
