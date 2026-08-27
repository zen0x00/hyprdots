hl.on("hyprland.start", function()
  hl.exec_cmd("openrgb -p white")
  hl.exec_cmd("uwsm app -- foot --server")
  hl.exec_cmd("uwsm app -- udiskie --no-automount --smart-tray")
  hl.exec_cmd("uwsm app -- awww-daemon")
  hl.exec_cmd("uwsm app -- abyssal-shell")
  -- reload config on monitor hotplug so monitors.lua re-evaluates
  hl.exec_cmd(
    [[bash -c 'socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do case "$line" in monitoradded*|monitorremoved*) hyprctl reload ;; esac; done']])
end)
