local function monitor_connected(name)
  local p = io.popen("cat /sys/class/drm/card*-" .. name .. "/status 2>/dev/null")
  if not p then
    return false
  end
  local out = p:read("*a")
  p:close()
  for line in out:gmatch("[^\n]+") do
    if line == "connected" then
      return true
    end
  end
  return false
end

if monitor_connected("DP-1") then
  hl.monitor({ output = "eDP-1", disabled = true })
  hl.monitor({ output = "DP-1", mode = "1920x1080@300.00", position = "0x0", scale = "1", })
elseif monitor_connected("HDMI-A-1") then
  hl.monitor({ output = "eDP-1", disabled = true })
  hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@180", position = "0x0", scale = "1", })
else
  hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = "1", })
end
