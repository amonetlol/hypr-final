-- Theme colors — sourced from theme engine (Hyprland Lua config)

local M = {}

M.general = {
    ["col.active_border"] = {
        colors = { "0xee7aa2f7", "0xee9ece6a" },
        angle = 45,
    },
    ["col.inactive_border"] = 0xaa24283b,
}

M.decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
        enabled = true,
        range = 12,
        render_power = 3,
        color = 0xee1a1b26,
    },
    blur = {
        enabled = true,
        size = 6,
        passes = 2,
        new_optimizations = true,
    },
}

M.group = {
    ["col.border_active"] = 0xee7aa2f7,
    ["col.border_inactive"] = 0xaa24283b,
    ["col.border_locked_active"] = 0xeef7768e,
    ["col.border_locked_inactive"] = 0xaa24283b,
}

return M
