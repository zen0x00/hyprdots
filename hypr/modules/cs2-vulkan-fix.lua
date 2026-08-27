local plugin_path = "@CSGO_VULKAN_FIX@/lib/libcsgo-vulkan-fix.so"

-- Hyprland 0.55 loads plugins through hyprctl. Reload after loading so the
-- plugin namespace is available to this Lua config.
hl.on("hyprland.start", function()
  hl.exec_cmd("bash -c 'hyprctl plugin load " .. plugin_path .. " && hyprctl reload'")
end)

-- The first parse happens before the plugin is loaded; the reload sees it.
if hl.plugin.csgo_vulkan_fix ~= nil then
  hl.plugin.csgo_vulkan_fix.vkfix_app({
    app = "cs2",
    w = 1920,
    h = 1080,
  })

  hl.config({
    plugin = {
      csgo_vulkan_fix = {
        fix_mouse = true,
      },
    },
  })
end
