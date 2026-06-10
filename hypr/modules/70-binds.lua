local programs = require("modules/01-programs")

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. "+ W", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || uwsm stop"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.file_manager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + SHIFT + F", function()
    hl.exec_cmd("hyprctl dispatch fullscreen 0")
end)

hl.bind("SUPER + space", hl.dsp.exec_cmd(programs.menu))
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("code"))
hl.bind("SUPER + SHIFT + Escape", hl.dsp.exec_cmd("zen0x-powermenu"))
hl.bind("SUPER + SHIFT + space", hl.dsp.exec_cmd("zen0x-theme-menu"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("zen0x-theme-reload"))

hl.bind(mainMod .. " + Left", function() hl.exec_cmd("hyprctl dispatch movefocus l") end)
hl.bind(mainMod .. " + Right", function() hl.exec_cmd("hyprctl dispatch movefocus r") end)
hl.bind(mainMod .. " + Up", function() hl.exec_cmd("hyprctl dispatch movefocus u") end)
hl.bind(mainMod .. " + Down", function() hl.exec_cmd("hyprctl dispatch movefocus d") end)
hl.bind(mainMod .. " + H", function() hl.exec_cmd("hyprctl dispatch movefocus l") end)
hl.bind(mainMod .. " + L", function() hl.exec_cmd("hyprctl dispatch movefocus r") end)
hl.bind(mainMod .. " + K", function() hl.exec_cmd("hyprctl dispatch movefocus u") end)
hl.bind(mainMod .. " + J", function() hl.exec_cmd("hyprctl dispatch movefocus d") end)

hl.bind(mainMod .. " + SHIFT + H", function() hl.exec_cmd("hyprctl dispatch swapwindow l") end)
hl.bind(mainMod .. " + SHIFT + L", function() hl.exec_cmd("hyprctl dispatch swapwindow r") end)
hl.bind(mainMod .. " + SHIFT + K", function() hl.exec_cmd("hyprctl dispatch swapwindow u") end)
hl.bind(mainMod .. " + SHIFT + J", function() hl.exec_cmd("hyprctl dispatch swapwindow d") end)

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + V", function() hl.exec_cmd("hyprctl dispatch togglefloating") end)
hl.bind(mainMod .. " + P", function() hl.exec_cmd("hyprctl dispatch pseudo") end)
hl.bind(mainMod .. " + G", function() hl.exec_cmd("hyprctl dispatch togglegroup") end)
hl.bind(mainMod .. " + Tab", function() hl.exec_cmd("hyprctl dispatch changegroupactive f") end)

hl.bind(mainMod .. " + CTRL + Right", function() hl.exec_cmd("hyprctl dispatch resizeactive 30 0") end, { repeating = true })
hl.bind(mainMod .. " + CTRL + Left", function() hl.exec_cmd("hyprctl dispatch resizeactive -30 0") end, { repeating = true })
hl.bind(mainMod .. " + CTRL + Up", function() hl.exec_cmd("hyprctl dispatch resizeactive 0 -30") end, { repeating = true })
hl.bind(mainMod .. " + CTRL + Down", function() hl.exec_cmd("hyprctl dispatch resizeactive 0 30") end, { repeating = true })
hl.bind(mainMod .. " + CTRL + L", function() hl.exec_cmd("hyprctl dispatch resizeactive 30 0") end, { repeating = true })
hl.bind(mainMod .. " + CTRL + H", function() hl.exec_cmd("hyprctl dispatch resizeactive -30 0") end, { repeating = true })
hl.bind(mainMod .. " + CTRL + K", function() hl.exec_cmd("hyprctl dispatch resizeactive 0 -30") end, { repeating = true })
hl.bind(mainMod .. " + CTRL + J", function() hl.exec_cmd("hyprctl dispatch resizeactive 0 30") end, { repeating = true })

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region | satty --filename -"))
hl.bind(mainMod .. " + mouse_down", function() hl.exec_cmd("hyprctl dispatch workspace e+1") end)
hl.bind(mainMod .. " + mouse_up", function() hl.exec_cmd("hyprctl dispatch workspace e-1") end)

hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
hl.bind("SUPER + mouse:273", hl.dsp.window.resize())

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })
hl.bind("Caps_Lock", hl.dsp.exec_cmd("swayosd-client --caps-lock"))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("SUPER + C", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -theme ~/.config/rofi/launcher.rasi | cliphist decode | wl-copy"))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))
