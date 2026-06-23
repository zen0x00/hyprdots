return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        opts = {},
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "rouge8/neotest-rust",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-rust"))
    end,
  },
}
