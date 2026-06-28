-- Theme colors — sourced from theme engine (Hyprland Lua config)

local M = {}

M.general = {
    ["col.active_border"] = {
        colors = { "0xee81a1c1", "0xeea3be8c" },
        angle = 45,
    },
    ["col.inactive_border"] = 0xaa434c5e,
}

M.decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
        enabled = true,
        range = 12,
        render_power = 3,
        color = 0xee2e3440,
    },
    blur = {
        enabled = true,
        size = 6,
        passes = 2,
        new_optimizations = true,
    },
}

M.group = {
    ["col.border_active"] = 0xee81a1c1,
    ["col.border_inactive"] = 0xaa434c5e,
    ["col.border_locked_active"] = 0xeebf616a,
    ["col.border_locked_inactive"] = 0xaa434c5e,
}

return M
