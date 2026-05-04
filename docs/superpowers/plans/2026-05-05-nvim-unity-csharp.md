# nvim Unity + C# Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire nvim as primary Unity editor with roslyn.nvim LSP, csharpier formatting, and netcoredbg DAP debugging targeting Unity Editor.

**Architecture:** LazyVim `lang.cs` extra provides treesitter-c_sharp; OmniSharp is disabled and replaced by `seblj/roslyn.nvim`. DAP uses `netcoredbg` (installed via Mason) in attach mode targeting the Unity Editor process. A wrapper script `bin/unity-nvim` translates Unity's file-open calls into nvim commands.

**Tech Stack:** Lua (LazyVim plugins), roslyn.nvim, nvim-dap, nvim-dap-ui, nvim-dap-virtual-text, netcoredbg, csharpier, conform.nvim, Bash (wrapper script)

---

### Task 1: Enable LazyVim lang.cs extra

**Files:**
- Modify: `nvim/lazyvim.json`

- [ ] **Step 1: Update lazyvim.json to add the lang.cs extra**

Replace the contents of `nvim/lazyvim.json` with:

```json
{
  "extras": [
    "lazyvim.plugins.extras.lang.cs"
  ],
  "install_version": 8,
  "news": {
    "NEWS.md": "11866"
  },
  "version": 8
}
```

- [ ] **Step 2: Verify the file**

```bash
cat /home/aman/dotfiles/nvim/lazyvim.json
```

Expected: `"lazyvim.plugins.extras.lang.cs"` present in extras array.

- [ ] **Step 3: Commit**

```bash
git -C /home/aman/dotfiles add nvim/lazyvim.json
git -C /home/aman/dotfiles commit -m "feat(nvim): enable LazyVim lang.cs extra"
```

---

### Task 2: Create C# plugin spec

**Files:**
- Create: `nvim/lua/plugins/csharp.lua`

- [ ] **Step 1: Create `nvim/lua/plugins/csharp.lua`**

```lua
return {
  -- Disable OmniSharp that lang.cs extra enables by default
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = { enabled = false },
      },
    },
  },

  -- Mason: netcoredbg (DAP adapter) + csharpier (formatter)
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "netcoredbg",
        "csharpier",
      },
    },
  },

  -- Roslyn LSP (replaces OmniSharp)
  -- Run :RoslynInstall inside nvim once after install to download the server binary
  {
    "seblj/roslyn.nvim",
    ft = "cs",
    opts = {
      config = {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|completion"] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
        },
      },
    },
  },

  -- csharpier formatter via conform.nvim
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
    },
  },

  -- DAP UI (auto-opens/closes with debug sessions)
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    ft = "cs",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- Inline variable values during debug session
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "cs",
    opts = {},
  },

  -- DAP: netcoredbg adapter + Unity attach config + keymaps
  {
    "mfussenegger/nvim-dap",
    ft = "cs",
    config = function()
      local dap = require("dap")

      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Attach to Unity Editor",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      vim.keymap.set("n", "<F5>",        dap.continue,          { desc = "DAP Continue" })
      vim.keymap.set("n", "<F9>",        dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
      vim.keymap.set("n", "<F10>",       dap.step_over,         { desc = "DAP Step Over" })
      vim.keymap.set("n", "<F11>",       dap.step_into,         { desc = "DAP Step Into" })
      vim.keymap.set("n", "<F12>",       dap.step_out,          { desc = "DAP Step Out" })
      vim.keymap.set("n", "<leader>du",  function() require("dapui").toggle() end, { desc = "DAP UI Toggle" })
    end,
  },
}
```

- [ ] **Step 2: Commit**

```bash
git -C /home/aman/dotfiles add nvim/lua/plugins/csharp.lua
git -C /home/aman/dotfiles commit -m "feat(nvim): add C# + Unity plugin config"
```

---

### Task 3: Create Unity → nvim wrapper script

**Files:**
- Create: `bin/unity-nvim`

Unity calls the external editor as: `<editor> <file> <line> <column>`

- [ ] **Step 1: Create `bin/unity-nvim`**

```bash
#!/usr/bin/env bash
# Called by Unity as: unity-nvim /path/to/File.cs <line> <column>
# Opens file at line in a running kitty window or a new one.

FILE="${1:-}"
LINE="${2:-1}"

if [[ -z "$FILE" ]]; then
  exec nvim
fi

exec nvim +"$LINE" "$FILE"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x /home/aman/dotfiles/bin/unity-nvim
```

- [ ] **Step 3: Verify it's in PATH (bin/ is stowed to /usr/bin)**

```bash
which unity-nvim
```

Expected: `/usr/bin/unity-nvim`

If not stowed yet:
```bash
sudo stow --dir=/home/aman/dotfiles --target=/usr --stow bin
```

- [ ] **Step 4: Commit**

```bash
git -C /home/aman/dotfiles add bin/unity-nvim
git -C /home/aman/dotfiles commit -m "feat(bin): add unity-nvim wrapper for external editor integration"
```

---

### Task 4: Post-install verification

These steps require nvim to be open and plugins installed.

- [ ] **Step 1: Open nvim and let lazy.nvim sync plugins**

```bash
nvim
```

Inside nvim: `:Lazy sync` — wait for all plugins to install including `seblj/roslyn.nvim`, `nvim-dap-ui`, `nvim-dap-virtual-text`.

- [ ] **Step 2: Install Roslyn language server**

Inside nvim: `:RoslynInstall`

Expected: Downloads and installs the Roslyn LSP binary. Takes ~30s. Output ends with "Roslyn installed".

- [ ] **Step 3: Verify Mason installs netcoredbg and csharpier**

Inside nvim: `:Mason`

Expected: `netcoredbg` and `csharpier` show as installed (green checkmark). If not, press `i` on each to install manually.

- [ ] **Step 4: Open a .cs file and verify LSP attaches**

```bash
# Open any Unity C# file (must have a .sln in the project root)
nvim /path/to/your/UnityProject/Assets/Scripts/SomeScript.cs
```

Inside nvim: `:LspInfo`

Expected: `roslyn` listed as active client for the buffer.

- [ ] **Step 5: Verify csharpier formats on save**

Open a `.cs` file, add some messy indentation, save with `:w`.

Expected: file is reformatted by csharpier on save.

- [ ] **Step 6: Configure Unity external editor**

In Unity Editor:
1. `Edit > Preferences > External Tools`
2. `External Script Editor` → browse to `/usr/bin/unity-nvim`
3. `External Script Editor Args` → leave blank (the wrapper handles args positionally)
4. Click `Regenerate project files`

Expected: clicking a script in Unity's Project panel opens it in nvim at the correct line.

- [ ] **Step 7: Test DAP attach**

In Unity Editor: ensure `Development Build` is checked in Build Settings, or just use the Editor (no build needed for Editor-mode debugging).

Inside nvim on a `.cs` file:
1. `<F9>` on a line to set a breakpoint
2. `<F5>` to start DAP — a process picker appears
3. Select the `Unity` process from the list
4. Trigger the code path in Unity that hits the breakpoint

Expected: DAP UI opens, execution pauses at breakpoint, variables visible in DAP UI panels.

---

## Unity Project Prerequisites (manual)

Before Roslyn LSP works, Unity must generate C# project files:

1. Open Unity Editor
2. `Edit > Preferences > External Tools`
3. Check all boxes under "Generate .csproj files for:"
4. Click **Regenerate project files**

Roslyn needs the `.sln` file at the Unity project root to resolve assemblies and provide accurate completions/diagnostics.
