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
