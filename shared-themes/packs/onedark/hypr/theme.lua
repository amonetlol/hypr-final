-- Theme colors — sourced from theme engine (Hyprland Lua config)

local M = {}

M.general = {
    ["col.active_border"] = {
        colors = { "0xee61afef", "0xee98c379" },
        angle = 45,
    },
    ["col.inactive_border"] = 0xaa2c323c,
}

M.decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    shadow = {
        enabled = true,
        range = 12,
        render_power = 3,
        color = 0xee282c34,
    },
    blur = {
        enabled = true,
        size = 6,
        passes = 2,
        new_optimizations = true,
    },
}

M.group = {
    ["col.border_active"] = 0xee61afef,
    ["col.border_inactive"] = 0xaa2c323c,
    ["col.border_locked_active"] = 0xeee06c75,
    ["col.border_locked_inactive"] = 0xaa2c323c,
}

return M
