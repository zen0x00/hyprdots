hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$",
	},
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "polished-common-dialogs",
	match = { title = "^(Open|Save|Save As|Choose|Select|File Upload)(.*)$" },
	float = true,
	center = true,
	size = { "monitor_w*0.6", "monitor_h*0.65" },
	opacity = "0.98 0.94",
})

hl.window_rule({
	name = "polished-picture-in-picture",
	match = { title = "^(Picture-in-Picture|Picture in picture)$" },
	float = true,
	pin = true,
	size = { "monitor_w*0.3", "monitor_h*0.3" },
	move = { "monitor_w*0.69", "monitor_h*0.64" },
	opacity = "0.96 0.90",
})

hl.window_rule({
	name = "airy-floating-windows",
	match = { float = true },
	rounding = 18,
	border_size = 3,
	opacity = "0.97 0.92",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

local steam_class = "^(steam|Steam|steamwebhelper)$"
local unityhub_class = "^(unityhub-bin|Unity Hub)$"
local unity_editor_popup_title = "^(?!.* - Unity( .*)?$).+"

hl.window_rule({
	name = "steam-floating",
	match = { class = steam_class },
	float = true,
	center = true,
	tag = "-default-opacity",
	opacity = "1 1",
	idle_inhibit = "fullscreen",
})

hl.window_rule({
	name = "steam-main-size",
	match = { class = steam_class, title = "^Steam$" },
	size = { 1400, 800 },
})

hl.window_rule({
	name = "steam-friends-size",
	match = { class = steam_class, title = "^Friends List$" },
	size = { 460, 800 },
})

hl.layer_rule({
	name = "no-anim-selection",
	match = { namespace = "selection" },
	no_anim = true,
})

hl.window_rule({
	name = "float-files",
	match = {
		class = "^(org.gnome.Nautilus|thunar)$",
		fullscreen = false,
	},
	float = true,
	center = true,
	size = { 1100, 700 },
})

hl.window_rule({
	name = "float-unityhub",
	match = {
		class = unityhub_class,
		fullscreen = false,
	},
	float = true,
	center = true,
	size = { 1100, 700 },
})

hl.window_rule({
	name = "float-android-studio-welcome",
	match = {
		class = "^(jetbrains-studio)$",
		title = "^Welcome to Android Studio$",
		fullscreen = false,
	},
	float = true,
	center = true,
	size = { 900, 600 },
})

hl.window_rule({
	name = "center-unity-popups",
	match = {
		class = "^Unity$",
		title = unity_editor_popup_title,
		fullscreen = false,
	},
	float = true,
	center = true,
})

hl.window_rule({
	name = "float-satty",
	match = {
		class = "^(com.gabm.satty)$",
		fullscreen = false,
	},
	float = true,
	center = true,
	size = { 900, 600 },
})

hl.window_rule({
	name = "float-spotify",
	match = {
		class = "^(Spotify)$",
		fullscreen = false,
	},
	float = true,
	center = true,
	size = { 1600, 800 },
})

hl.window_rule({
	name = "float-nwg-look",
	match = {
		class = "^(nwg-look)$",
		fullscreen = false,
	},
	float = true,
	center = true,
	size = { 1200, 800 },
})

hl.window_rule({
	name = "float-terminal-launcher",
	match = {
		class = "^(org.zen0x.floating-terminal)$",
		fullscreen = false,
	},
	float = true,
	center = true,
	size = { 1100, 700 },
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = { 20, "monitor_h-120" },
	float = true,
})

for i = 1, 5 do
	hl.workspace_rule({
		workspace = tostring(i),
		persistent = true,
	})
end

hl.window_rule({
	name = "ws1",
	match = { class = "^(zen|Zen)$" },
	workspace = "1",
})
hl.window_rule({
	name = "ws2",
	match = { class = "^(kitty|Kitty|Alacritty|WezTerm|foot)$" },
	workspace = "2",
})
hl.window_rule({
	name = "ws3",
	match = { class = "^(code|Code|vscode|VSCode)$" },
	workspace = "3",
})
hl.window_rule({
	name = "ws4",
	match = { class = "^(unityhub|Unity Hub|Unity|Spotify)$" },
	workspace = "4",
})
hl.window_rule({
	name = "ws5",
	match = { class = "^(steam|Steam|heroic|Heroic)$" },
	workspace = "5",
})
hl.window_rule({
	name = "ws6",
	match = { title = "^(.*%.exe|.*game|.*Game)$" },
	workspace = "6",
})
