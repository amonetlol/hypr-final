-- Theme colors — sourced from theme engine (Hyprland Lua config)

local M = {}

M.general = {
    ["col.active_border"] = {
        colors = { "0xee9e9e9e", "0xeeb0b0b0" },
        angle = 45,
    },
    ["col.inactive_border"] = 0xaa2d2d2d,
}

M.decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
        enabled = true,
        range = 12,
        render_power = 3,
        color = 0xee1e1e1e,
    },
    blur = {
        enabled = true,
        size = 6,
        passes = 2,
        new_optimizations = true,
    },
}

M.group = {
    ["col.border_active"] = 0xee9e9e9e,
    ["col.border_inactive"] = 0xaa2d2d2d,
    ["col.border_locked_active"] = 0xeec75050,
    ["col.border_locked_inactive"] = 0xaa2d2d2d,
}

return M
