hl.layer_rule({
    name = "blur-waybar",
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name = "blur-rofi",
    match = { namespace = "rofi" },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name = "blur-swaync-cc",
    match = { namespace = "swaync-control-center" },
    blur = true,
    ignore_alpha = 0.6,
})

hl.layer_rule({
    name = "blur-swaync-notif",
    match = { namespace = "swaync-notification-window" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "blur-swayosd",
    match = { namespace = "swayosd" },
    blur = true,
    ignore_alpha = 0.5,
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

hl.window_rule({
    name = "fix-marvelrivals-artifacts",
    match = { class = "^marvelrivals_launcher.exe$" },
    no_shadow = true,
    no_blur = true,
    no_dim = true,
    border_size = 0,
    rounding = 0,
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

hl.layer_rule({ name = "no-anim-selection", match = { namespace = "selection" }, no_anim = true })

hl.window_rule({
    name = "float-files",
    match = { class = "^(org.gnome.Nautilus|thunar)$", fullscreen = false },
    float = true,
    center = true,
    size = { 1100, 700 },
})

hl.window_rule({
    name = "float-unityhub",
    match = { class = unityhub_class, fullscreen = false },
    float = true,
    center = true,
    size = { 1100, 700 },
})

hl.window_rule({
    name = "center-unity-popups",
    match = { class = "^Unity$", title = unity_editor_popup_title, fullscreen = false },
    float = true,
    center = true,
})

hl.window_rule({
    name = "float-satty",
    match = { class = "^(com.gabm.satty)$", fullscreen = false },
    float = true,
    center = true,
    size = { 1200, 800 },
})

hl.window_rule({
    name = "float-nwg-look",
    match = { class = "^(nwg-look)$", fullscreen = false },
    float = true,
    center = true,
    size = { 1200, 800 },
})

hl.window_rule({
    name = "float-zen0x-utility-tuis",
    match = { class = "^(org.zen0x.wiremix|org.zen0x.impala|org.zen0x.bluetui)$", fullscreen = false },
    float = true,
    center = true,
    size = { 1100, 700 },
})

hl.window_rule({
    name = "float-terminal-launcher",
    match = { class = "^(org.zen0x.floating-terminal)$", fullscreen = false },
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

hl.window_rule({ name = "ws1-zen-browser", match = { class = "^(zen|Zen)$" }, workspace = "1" })
hl.window_rule({ name = "ws2-terminal", match = { class = "^(kitty|Kitty|Alacritty|WezTerm|foot)$" }, workspace = "2" })
hl.window_rule({ name = "ws3-vscode", match = { class = "^(code|Code|vscode|VSCode)$" }, workspace = "3" })
hl.window_rule({ name = "ws4-unity", match = { class = "^(unityhub|Unity Hub|Unity)$" }, workspace = "4" })
hl.window_rule({ name = "ws5-steam-heroic", match = { class = "^(steam|Steam|heroic|Heroic)$" }, workspace = "5" })
hl.window_rule({ name = "ws6-games", match = { title = "^(.*%.exe|.*game|.*Game)$" }, workspace = "6" })
