local probe = io.popen('sh -c \'ls /sys/class/drm | grep -q "HDMI" && echo 1 || echo 0\'')
local hdmi_connected = probe and probe:read("*l") == "1"
if probe then
  probe:close()
end

if hdmi_connected then
  hl.monitor({ output = "eDP-1", disabled = true })
  hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@180", position = "0x0", scale = "1" })
else
  hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = "1",  })
end
