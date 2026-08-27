hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})

hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "capitaine-cursors-white")
hl.env("HYPRCURSOR_THEME", "capitaine-cursors-white")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("NIXOS_OZONE_WL", "1")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GNOME_KEYRING_CONTROL", os.getenv("XDG_RUNTIME_DIR") .. "/keyring")
hl.env("PROTON_PASS_KEY_PROVIDER", "fs")
