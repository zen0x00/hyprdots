general {
    hide_cursor = true
    grace = 3
    no_fade_in = false
    no_fade_out = false
    ignore_empty_input = true
    text_trim = true
}

background {
    monitor =
    path = ~/.config/hypr/wallpaper.jpg
    blur_size = 8
    blur_passes = 4
    brightness = 0.60
    noise = 0.04
    contrast = 0.90
    vibrancy = 0.22
    vibrancy_darkness = 0.40
}

# Clock
label {
    monitor =
    text = cmd[update:1000] echo "<b>$(date +"%H:%M")</b>"
    color = rgba({{ semantic.fg | strip_hash }}ee)
    font_size = 112
    font_family = JetBrainsMono Nerd Font
    position = 0, 260
    halign = center
    valign = center
    shadow_passes = 3
    shadow_size = 6
    shadow_color = rgba({{ semantic.bg | strip_hash }}bb)
    shadow_boost = 1.2
}

# Date
label {
    monitor =
    text = cmd[update:60000] echo "$(date +"%A · %B %d, %Y")"
    color = rgba({{ semantic.muted | strip_hash }}ee)
    font_size = 24
    font_family = JetBrainsMono Nerd Font
    position = 0, 130
    halign = center
    valign = center
    shadow_passes = 2
    shadow_size = 4
    shadow_color = rgba({{ semantic.bg | strip_hash }}99)
    shadow_boost = 1.1
}

# Divider
label {
    monitor =
    text = ─────────────────
    color = rgba({{ semantic.border | strip_hash }}66)
    font_size = 14
    font_family = JetBrainsMono Nerd Font
    position = 0, 40
    halign = center
    valign = center
}

# User
label {
    monitor =
    text =   $USER
    color = rgba({{ semantic.muted | strip_hash }}cc)
    font_size = 17
    font_family = JetBrainsMono Nerd Font
    position = 0, -48
    halign = center
    valign = center
    shadow_passes = 1
    shadow_size = 3
    shadow_color = rgba({{ semantic.bg | strip_hash }}88)
}

# Password input
input-field {
    monitor =
    size = 340, 58
    outline_thickness = 2
    dots_size = 0.30
    dots_spacing = 0.18
    dots_center = true
    dots_rounding = -1
    outer_color = rgba({{ semantic.accent | strip_hash }}cc)
    inner_color = rgba({{ semantic.bg | strip_hash }}bb)
    font_color = rgba({{ semantic.fg | strip_hash }}ff)
    font_family = JetBrainsMono Nerd Font
    fade_on_empty = true
    fade_timeout = 1200
    placeholder_text = <span foreground="##{{ semantic.muted | strip_hash }}"><i>󰌾  Password</i></span>
    hide_input = false
    rounding = 14
    check_color = rgba({{ semantic.success | strip_hash }}ff)
    fail_color = rgba({{ semantic.danger | strip_hash }}ff)
    fail_text = <span foreground="##{{ semantic.danger | strip_hash }}"><b>$FAIL</b> ($ATTEMPTS)</span>
    fail_transition = 300
    capslock_color = rgba({{ semantic.warning | strip_hash }}ff)
    numlock_color = rgba({{ semantic.accent | strip_hash }}ff)
    bothlock_color = rgba({{ semantic.danger | strip_hash }}ff)
    swap_font_color = false
    position = 0, -135
    halign = center
    valign = center
}

# Hint
label {
    monitor =
    text = Press Enter to unlock
    color = rgba({{ semantic.subtle | strip_hash }}88)
    font_size = 13
    font_family = JetBrainsMono Nerd Font
    position = 0, -215
    halign = center
    valign = center
}
