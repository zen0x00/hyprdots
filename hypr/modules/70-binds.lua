local programs = require("modules/01-programs")

local mainMod = "SUPER"
local ipc = "noctalia msg"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(programs.terminal .. " --class org.zen0x.floating-terminal"))
hl.bind(mainMod .. "+ W", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || uwsm stop"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.file_manager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + SHIFT + F", function()
    hl.exec_cmd("hyprctl dispatch fullscreen 0")
end)

hl.bind(mainMod .. "+Space", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"))
hl.bind(mainMod .. "+C", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"))
hl.bind(mainMod .. "+comma", hl.dsp.exec_cmd(ipc .. " settings-toggle"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("code"))
hl.bind("SUPER + SHIFT + Escape", hl.dsp.exec_cmd("zen0x-powermenu"))

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

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("zen0x-capture-screenshot region"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("zen0x-capture-ocr"))
hl.bind(mainMod .. " + ALT + M", hl.dsp.exec_cmd("zen0x-audio-output-switch"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("zen0x-capture-screenrecording region"))

hl.bind("SUPER + LEFT", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + UP", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + DOWN", hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + SHIFT + LEFT", hl.dsp.window.swap({ direction = "l" }))
hl.bind("SUPER + SHIFT + RIGHT", hl.dsp.window.swap({ direction = "r" }))
hl.bind("SUPER + SHIFT + UP", hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + SHIFT + DOWN", hl.dsp.window.swap({ direction = "d" }))

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", function() hl.exec_cmd("hyprctl dispatch pseudo") end)
hl.bind(mainMod .. " + G", function() hl.exec_cmd("hyprctl dispatch togglegroup") end)
hl.bind(mainMod .. " + Tab", function()
    if hl.plugin and hl.plugin.scrolloverview then
        hl.plugin.scrolloverview.overview("toggle")
    end
end)

hl.bind("Print", hl.dsp.exec_cmd("zen0x-capture-screenshot smart"))
hl.bind(mainMod .. " + mouse_down", function() hl.exec_cmd("hyprctl dispatch workspace e+1") end)
hl.bind(mainMod .. " + mouse_up", function() hl.exec_cmd("hyprctl dispatch workspace e-1") end)

hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
hl.bind("SUPER + mouse:273", hl.dsp.window.resize())

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. " volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. " brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. " brightness-down"))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))
