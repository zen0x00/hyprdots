# nvim Unity + C# Setup

**Date:** 2026-05-05  
**Status:** Approved

## Goal

Configure nvim as the primary Unity editor with full C# LSP (roslyn.nvim), formatting (csharpier), and DAP debugging (netcoredbg attached to Unity Editor).

## Approach

LazyVim `lang.cs` extra for treesitter-c_sharp + neotest-dotnet infra, with OmniSharp disabled and replaced by roslyn.nvim. DAP via nvim-dap + netcoredbg targeting Unity Editor's debug port.

## Components

### Plugins — `nvim/lua/plugins/csharp.lua`

| Plugin | Purpose |
|---|---|
| `seblj/roslyn.nvim` | C# LSP via Roslyn language server |
| `nvim-dap` | DAP client (already in LazyVim) |
| `nvim-dap-ui` | Debugger UI panels |
| `nvim-dap-virtual-text` | Inline variable values during debug session |
| `conform.nvim` override | Hook csharpier as formatter for `.cs` files |
| Disable `omnisharp` | Prevent lang.cs extra from starting OmniSharp |

### LazyVim extra — `nvim/lazyvim.json`

Add `lazyvim.plugins.extras.lang.cs` — provides:
- treesitter `c_sharp` grammar
- neotest-dotnet integration

### Mason installs — inside `csharp.lua`

- `roslyn` — Roslyn language server binary
- `netcoredbg` — .NET DAP adapter
- `csharpier` — C# formatter

### DAP config — `nvim/lua/plugins/csharp.lua`

- Adapter: `netcoredbg` executable from Mason path
- Configuration: `attach` mode targeting Unity Editor debug port `56000`
- Keymaps (set only for `cs` filetype):
  - `<F5>` — continue
  - `<F9>` — toggle breakpoint
  - `<F10>` — step over
  - `<F11>` — step into
  - `<F12>` — step out
  - `<leader>du` — toggle DAP UI

### Unity → nvim wrapper — `bin/unity-nvim`

Bash script Unity calls when opening a script. Translates Unity's open command (`file line column`) into `nvim +{line} {file}`. Set in Unity: `Preferences > External Tools > External Script Editor`.

### conform.nvim formatter

Override conform.nvim formatters_by_ft to add `csharpier` for `cs` files. Format on save via LazyVim's existing conform setup.

## Data Flow

```
Unity clicks script
    │
    ▼
bin/unity-nvim (wrapper)
    │ nvim +{line} {file}
    ▼
nvim opens file
    │
    ├── roslyn.nvim → Roslyn LSP server → reads .sln / .csproj
    │       └── diagnostics, completion, go-to-def, hover
    │
    ├── conform.nvim → csharpier → format on save
    │
    └── nvim-dap → netcoredbg → attach to Unity Editor :56000
            └── breakpoints, step, inspect variables
```

## Prerequisites (manual, outside nvim)

1. Unity: `Preferences > External Tools > External Script Editor` → set to `unity-nvim` script path
2. Unity: click "Regenerate project files" to create `.csproj` / `.sln` (Roslyn needs these)
3. Unity: enable `Development Build` + `Script Debugging` for runtime DAP; Editor DAP works without this

## Files Changed

| Action | Path |
|---|---|
| create | `nvim/lua/plugins/csharp.lua` |
| create | `bin/unity-nvim` |
| modify | `nvim/lazyvim.json` (add lang.cs extra) |

## Out of Scope

- neotest-dotnet test runner config (can be added later)
- Runtime (built game) debugging — Editor debugging only
- `.editorconfig` for Unity style rules
