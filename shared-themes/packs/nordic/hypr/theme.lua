-- Theme colors — sourced from theme engine (Hyprland Lua config)

local M = {}

M.general = {
    ["col.active_border"] = {
        colors = { "0xee88c0d0", "0xeea3be8c" },
        angle = 45,
    },
    ["col.inactive_border"] = 0xaa3b4252,
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
    ["col.border_active"] = 0xee88c0d0,
    ["col.border_inactive"] = 0xaa3b4252,
    ["col.border_locked_active"] = 0xeebf616a,
    ["col.border_locked_inactive"] = 0xaa3b4252,
}

return M
