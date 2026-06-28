-- Window + layer rules (Hyprland 0.55+ Lua)
-- Copy to ~/.config/hypr/window-rules.lua and require from hyprland.lua

-------------------------
---- Floating dialogs ----
-------------------------

hl.window_rule({
	name = "floating-terminals",
	match = { class = "foot-float|alacritty-float|kitty-float" },
	float = true,
})

local float_dialogs = {
	"yad",
	"nm-connection-editor",
	"xfce-polkit",
	"kvantummanager",
	"qt5ct",
	"qt6ct",
	"feh",
	"viewnior",
	"gimp",
	"MPlayer",
	"VirtualBox Manager",
	"qemu",
	"Qemu-system-x86_64",
	"Yad",
	"io.calamares.calamares",
}

for _, cls in ipairs(float_dialogs) do
	hl.window_rule({ match = { class = cls }, float = true })
end

hl.window_rule({ match = { title = "File Operation Progress" }, float = true })
hl.window_rule({ match = { title = "Confirm to replace files" }, float = true })
hl.window_rule({ match = { class = "gmetronome" }, float = true })

-------------------------
---- Sized / centered ----
-------------------------

hl.window_rule({
	match = { class = "org.pulseaudio.pavucontrol" },
	float = true,
	size = { 800, 600 },
})

hl.window_rule({
	match = { class = "thunar", title = "Rename .*" },
	float = true,
})

hl.window_rule({
	match = { class = "Yad|yad" },
	float = true,
	size = { "60% monitor_w", "64% monitor_h" },
})

hl.window_rule({
	match = { class = "io.calamares.calamares" },
	float = true,
	center = true,
})

hl.window_rule({
	match = { title = "^(Archcraft Installer)(.*)$" },
	float = true,
})

hl.window_rule({
	match = { class = "viewnior" },
	size = { 800, 600 },
	center = true,
})

hl.window_rule({
	match = { class = "Alacritty|alacritty|alacritty-float" },
	size = { 785, 450 },
})

-------------------------
---- Animations ---------
-------------------------

hl.window_rule({
	match = { class = "foot-full|alacritty-full|kitty-full" },
	animation = "slide down",
})

hl.window_rule({
	match = { class = "wlogout" },
	animation = "slide up",
})

-------------------------
---- Apps / workspaces --
-------------------------

hl.window_rule({
	match = { class = "Blueman-manager|blueman-manager" },
	float = true,
	size = { 638, 506 },
	move = { 18, 242 },
	workspace = "9 silent",
})

hl.window_rule({
	match = { class = "gmetronome" },
	float = true,
	size = { 487, 391 },
	move = { 1327, 305 },
	workspace = "9 silent",
})

hl.window_rule({ match = { class = "firefox" }, workspace = "2" })

hl.window_rule({
	match = { class = "firefox", title = "Picture-in-Picture" },
	float = true,
	move = { "monitor_w - window_w - 40", "monitor_h - window_h - 40" },
})

local media_workspace = {
	"mpv",
	"vlc",
	"org%.videolan%.vlc",
	"celluloid",
	"io%.github%.celluloid_player%.Celluloid",
	"io%.github%.diegopvlk%.Cine",
}

for _, cls in ipairs(media_workspace) do
	hl.window_rule({ match = { class = cls }, workspace = "8 silent" })
end

-------------------------
---- Layer rules --------
-------------------------

hl.layer_rule({ match = { namespace = "rofi" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "notifications" }, animation = "slide" })
