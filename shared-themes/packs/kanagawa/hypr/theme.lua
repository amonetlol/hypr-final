-- Theme colors — sourced from theme engine (Hyprland Lua config)

local M = {}

M.general = {
    ["col.active_border"] = {
        colors = { "0xee7e9cd8", "0xee98bb6c" },
        angle = 45,
    },
    ["col.inactive_border"] = 0xaa2a2a37,
}

M.decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
        enabled = true,
        range = 12,
        render_power = 3,
        color = 0xee1f1f28,
    },
    blur = {
        enabled = true,
        size = 6,
        passes = 2,
        new_optimizations = true,
    },
}

M.group = {
    ["col.border_active"] = 0xee7e9cd8,
    ["col.border_inactive"] = 0xaa2a2a37,
    ["col.border_locked_active"] = 0xeec34043,
    ["col.border_locked_inactive"] = 0xaa2a2a37,
}

return M
