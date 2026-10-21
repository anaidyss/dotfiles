-- Diagnostics & refactor: trouble (diagnostics panel), todo-comments,
-- spectre (project-wide search/replace).
return {
  -- diagnostics panel
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix (Trouble)" },
    },
    config = function()
      require("trouble").setup({
        icons = true,
        fold_open = "▾",
        fold_closed = "▸",
        padding = true,
      })
    end,
  },

  -- highlight TODO/FIXME/HACK/etc
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO" },
      { "<leader>xt", "<cmd>TodoTelescope<cr>", desc = "TODO list" },
    },
    config = function()
      require("todo-comments").setup({
        signs = true,
        highlight = {
          multiline = true,
          before = "",
          keyword = "wide",
          after = "fg",
        },
      })
    end,
  },

  -- project-wide search & replace
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    keys = {
      { "<leader>sr", "<cmd>Spectre<cr>", desc = "Search & replace (Spectre)" },
    },
    config = function()
      require("spectre").setup({
        highlight = { ui = "String" },
      })
    end,
  },
}
