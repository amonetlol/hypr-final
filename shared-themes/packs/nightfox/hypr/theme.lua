-- Theme colors — sourced from theme engine (Hyprland Lua config)

local M = {}

M.general = {
    ["col.active_border"] = {
        colors = { "0xee719cd6", "0xee81b29a" },
        angle = 45,
    },
    ["col.inactive_border"] = 0xaa212f3b,
}

M.decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
        enabled = true,
        range = 12,
        render_power = 3,
        color = 0xee192330,
    },
    blur = {
        enabled = true,
        size = 6,
        passes = 2,
        new_optimizations = true,
    },
}

M.group = {
    ["col.border_active"] = 0xee719cd6,
    ["col.border_inactive"] = 0xaa212f3b,
    ["col.border_locked_active"] = 0xeec94f6d,
    ["col.border_locked_inactive"] = 0xaa212f3b,
}

return M
