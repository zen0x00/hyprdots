# nvim Theme Sync

**Date:** 2026-05-04  
**Status:** Approved

## Goal

Sync nvim colorscheme with the zen0x theme engine so that running `zen0x-apply-theme <slug>` also re-themes any live nvim instances, using exact hex values from `colors.toml`.

## Components

### 1. Template: `templates/nvim/colors.lua.tpl`

Renders a Lua module returning a flat table of all semantic and palette color values from the active theme's `colors.toml`. Written to `~/.config/nvim/lua/zen0x/colors.lua` on each theme switch.

Example output:
```lua
return {
  bg      = "#1e1e2e",
  fg      = "#cdd6f4",
  accent  = "#89b4fa",
  -- ... all semantic.* and palette.* keys
}
```

### 2. Generated file: `~/.config/nvim/lua/zen0x/colors.lua`

Output of the template render. Not tracked in git (gitignored). Loaded at nvim startup by the colorscheme plugin.

### 3. Static plugin: `nvim/lua/plugins/zen0x-theme.lua`

Version-controlled. Defines colorscheme `zen0x`. On load:
- `require("zen0x.colors")` to get the color table
- Sets all highlight groups using `vim.api.nvim_set_hl`

Highlight mapping:

| nvim group | source key |
|---|---|
| Normal | bg=semantic.bg, fg=semantic.fg |
| NormalFloat | bg=semantic.panel, fg=semantic.fg |
| CursorLine, ColorColumn | bg=semantic.surface |
| StatusLine, TabLine | bg=semantic.panel, fg=semantic.fg |
| FloatBorder, WinSeparator | fg=semantic.border |
| Comment, LineNr, NonText | fg=semantic.muted |
| CursorLineNr | fg=semantic.subtle |
| Keyword, Statement, Special, @keyword | fg=semantic.accent |
| Function, @function, @method | fg=semantic.accent_alt |
| String, @string | fg=semantic.success |
| Type, @type | fg=semantic.warning |
| Error, DiagnosticError, @error | fg=semantic.danger |
| DiagnosticWarn | fg=semantic.warning |
| DiagnosticInfo | fg=semantic.accent |
| DiagnosticOk | fg=semantic.success |
| Constant, @constant | fg=palette.red_light |
| Number, @number | fg=palette.orange_light |
| Boolean, @boolean | fg=palette.red_dark |
| Operator, @operator | fg=semantic.fg |
| Identifier, @variable | fg=semantic.fg |
| Visual | bg=semantic.elevated |
| Search, IncSearch | bg=semantic.accent, fg=semantic.bg |
| Pmenu | bg=semantic.panel, fg=semantic.fg |
| PmenuSel | bg=semantic.elevated, fg=semantic.fg |
| PmenuSbar | bg=semantic.surface |
| PmenuThumb | bg=semantic.accent |
| GitSignsAdd | fg=semantic.success |
| GitSignsChange | fg=semantic.warning |
| GitSignsDelete | fg=semantic.danger |

### 4. `zen0x-generate-theme` change

Add entry to `TEMPLATE_TARGETS`:
```python
("templates/nvim/colors.lua.tpl", "~/.config/nvim/lua/zen0x/colors.lua"),
```

### 5. `zen0x-theme-reload` change

After existing reload steps, add nvim socket loop:
```bash
for sock in /run/user/$(id -u)/nvim.*.0; do
    [[ -S "$sock" ]] && nvim --server "$sock" --remote-send ':colorscheme zen0x<CR>' 2>/dev/null || true
done
```

## Data Flow

```
colors.toml
    │
    ▼
zen0x-generate-theme (Python template render)
    │
    ▼
~/.config/nvim/lua/zen0x/colors.lua   (generated, gitignored)
    │
    ▼ require("zen0x.colors")
nvim/lua/plugins/zen0x-theme.lua      (static, version-controlled)
    │
    ▼
vim.api.nvim_set_hl → all highlight groups applied

zen0x-theme-reload
    │
    ▼ nvim --server $sock --remote-send ':colorscheme zen0x<CR>'
running nvim instances reload colorscheme
```

## Files Changed

| Action | Path |
|---|---|
| create | `templates/nvim/colors.lua.tpl` |
| create | `nvim/lua/plugins/zen0x-theme.lua` |
| create | `nvim/.gitignore` (ignore `lua/zen0x/colors.lua`) |
| modify | `bin/zen0x-generate-theme` (add TEMPLATE_TARGETS entry) |
| modify | `bin/zen0x-theme-reload` (add nvim socket loop) |

## Out of Scope

- Treesitter semantic token overrides beyond the `@`-prefixed groups listed above
- Plugin-specific highlights (telescope, neo-tree, etc.) — can be added incrementally
- Lualine/statusline plugin theming — separate concern
