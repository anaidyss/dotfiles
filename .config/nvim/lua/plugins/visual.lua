-- Visual framing: a styled statuscolumn (left gutter), a winbar with
-- breadcrumbs, and mini.nvim animations. Together these turn nvim from a
-- "floating terminal" into a framed editor window.

return {
  -- styled left gutter: fold + sign + relative line numbers in one column
  {
    "luukvbaal/statuscol.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { text = { "%s" }, click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
        },
      })
      -- subtle gutter background to frame the code
      vim.api.nvim_set_hl(0, "StatusColumn", { bg = "#1a1b19" })
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#5c5c58" })
    end,
  },

  -- winbar with breadcrumbs (class → method) at the top of each window
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    event = "VeryLazy",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("barbecue").setup({
        attach_navic = true,
        theme = "gruvbox",
        exclude_filetypes = { "netrw", "toggleterm", "dashboard", "alpha", "neo-tree" },
      })
    end,
  },

  -- smooth cursor/scroll/window animations
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    config = function()
      require("mini.animate").setup({
        cursor = { enable = true },
        scroll = { enable = true },
        resize = { enable = true },
        open = { enable = true },
        close = { enable = true },
      })
    end,
  },

  -- animated highlight of the current indent scope
  {
    "echasnovski/mini.indentscope",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mini.indentscope").setup({
        symbol = "│",
      })
    end,
  },

  -- highlight the word under the cursor
  {
    "echasnovski/mini.cursorword",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mini.cursorword").setup({
        delay = 200,
      })
    end,
  },
}
