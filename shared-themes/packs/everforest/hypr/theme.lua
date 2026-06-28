-- Theme colors — sourced from theme engine (Hyprland Lua config)

local M = {}

M.general = {
    ["col.active_border"] = {
        colors = { "0xee7fbbb3", "0xeea7c080" },
        angle = 45,
    },
    ["col.inactive_border"] = 0xaa3d484d,
}

M.decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
        enabled = true,
        range = 12,
        render_power = 3,
        color = 0xee2d353b,
    },
    blur = {
        enabled = true,
        size = 6,
        passes = 2,
        new_optimizations = true,
    },
}

M.group = {
    ["col.border_active"] = 0xee7fbbb3,
    ["col.border_inactive"] = 0xaa3d484d,
    ["col.border_locked_active"] = 0xeee67e80,
    ["col.border_locked_inactive"] = 0xaa3d484d,
}

return M
