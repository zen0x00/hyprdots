hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",
    follow_mouse = 1,
    accel_profile = "flat",
    sensitivity = 0,
    repeat_rate = 35,
    repeat_delay = 220,
    touchpad = {
      natural_scroll = true,
    },
  },
})

-- Touchpad: re-enable accel (global is flat for mouse)
hl.device({
  name = ".*touchpad.*",
  accel_profile = "adaptive",
})

-- Touchpad gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 4, direction = "down", action = "special", workspace_name = "term" })
