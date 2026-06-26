 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#1c1e21',
    base01 = '#2f3237',
    base02 = '#2a2d32',
    base03 = '#64696e',
    base04 = '#b0b2b5',
    base05 = '#f2f2f3',
    base06 = '#f2f2f3',
    base07 = '#f2f2f3',
    base08 = '#fd4663',
    base09 = '#908fa3',
    base0A = '#8d91a5',
    base0B = '#98a4b3',
    base0C = '#bab9c5',
    base0D = '#b6bec9',
    base0E = '#b8bac7',
    base0F = '#533d41',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#f2f2f3',          bg = '#1c1e21' })
  hi('TelescopeBorder',         { fg = '#64696e',             bg = '#1c1e21' })
  hi('TelescopePromptNormal',   { fg = '#f2f2f3',          bg = '#1c1e21' })
  hi('TelescopePromptBorder',   { fg = '#64696e',             bg = '#1c1e21' })
  hi('TelescopePromptPrefix',   { fg = '#98a4b3',             bg = '#1c1e21' })
  hi('TelescopePromptCounter',  { fg = '#b0b2b5',  bg = '#1c1e21' })
  hi('TelescopePromptTitle',    { fg = '#1c1e21',             bg = '#98a4b3' })
  hi('TelescopePreviewTitle',   { fg = '#1c1e21',             bg = '#8d91a5' })
  hi('TelescopeResultsTitle',   { fg = '#1c1e21',             bg = '#908fa3' })
  hi('TelescopeSelection',      { fg = '#f2f2f3',          bg = '#2a2d32' })
  hi('TelescopeSelectionCaret', { fg = '#98a4b3',             bg = '#2a2d32' })
  hi('TelescopeMatching',       { fg = '#98a4b3',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
