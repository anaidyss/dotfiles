-- Small QoL editor plugins grouped in one file:
-- which-key (leader hints), bracket autopairs, indent guides.
-- Comment (gc) is built into nvim 0.10+ — no separate plugin needed.

return {
  -- key hints on leader press
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        preset = "modern",
        delay = 250,
        icons = { separator = "→", group = "" },
        win = { border = "rounded" },
      })
      -- leader-key groups (shown as sections in which-key)
      require("which-key").add({
        { "<leader>f", group = "find" },
        { "<leader>g", group = "grep" },
        { "<leader>b", group = "buffers" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>e", group = "explorer" },
        { "<leader>c", group = "code" },
        { "<leader>h", group = "git/history" },
        { "<leader>l", group = "LSP" },
        { "<leader>q", group = "quit" },
        { "<leader>w", group = "save" },
      }, { mode = "n", silent = true })
    end,
  },

  -- auto-close brackets/quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({ check_ts = true, fast_wrap = {} })
      -- nvim-cmp integration: <CR> adds the closing bracket
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end
    end,
  },

-- vertical indent guides with a rainbow gradient (easy to see nesting)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- rainbow: each indent level gets a slightly different forest tint
      local rainbow = {
        "#2c3f34",
        "#3a4f42",
        "#4a5f52",
        "#59c2a5",
        "#7fb8ad",
        "#a48bb5",
      }
      for i, color in ipairs(rainbow) do
        vim.api.nvim_set_hl(0, "IblIndent" .. i, { fg = color })
      end
      vim.api.nvim_set_hl(0, "IblScope", { fg = "#a6e3a1" })
      require("ibl").setup({
        indent = { char = "│", highlight = { "IblIndent1", "IblIndent2", "IblIndent3", "IblIndent4", "IblIndent5", "IblIndent6" } },
        scope = { enabled = true, highlight = "IblScope", show_start = false, show_end = false },
        exclude = { filetypes = { "help", "neo-tree", "dashboard", "lazy", "mason" } },
      })
    end,
  },
}
