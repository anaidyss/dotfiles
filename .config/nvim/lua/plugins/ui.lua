-- Visual polish: nicer cmdline/messages (noice), pretty notifications
-- (notify), a start dashboard (alpha), hex color preview (colorizer),
-- a scrollbar, and breadcrumbs (navic). All themed to forest.

return {
  -- pretty notifications (also used by noice)
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup({
        background_colour = "#1e1f1c",
        timeout = 3000,
        max_width = 60,
        max_height = 20,
        render = "default",
        stages = "fade_in_slide_out",
        top_down = true,
      })
      vim.notify = require("notify")
    end,
  },

  -- nicer cmdline, messages, popupmenu, search
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          hover = { enabled = true },
          signature = { enabled = true },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = true,
          lsp_doc_border = true,
        },
      })
    end,
  },

  -- start dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      local utils = require("alpha.utils")

      dashboard.section.header.val = {
        "        ▲",
        "       ▲▲▲",
        "      ▲▲▲▲▲",
        "     ▲▲▲▲▲▲▲",
        "    ▲▲▲▲▲▲▲▲▲",
        "       │││",
        "       │││",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
        dashboard.button("g", "  Grep text", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("e", "  File tree", "<cmd>Neotree toggle<CR>"),
        dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
      }

      -- recent files section (most recently used, centered)
      local function mru_section()
        local files = utils.get_mru(vim.fn.getcwd(), 5)
        local items = {}
        for _, f in ipairs(files) do
          table.insert(items, { type = "text", val = "  " .. f, opts = { position = "center", hl = "Comment" } })
        end
        if #items == 0 then
          return { type = "text", val = "", opts = { position = "center" } }
        end
        return {
          type = "group",
          val = {
            { type = "text", val = "Recent files", opts = { position = "center", hl = "SpecialComment" } },
            { type = "padding", val = 1 },
            { type = "group", val = items },
          },
        }
      end

      dashboard.section.footer.val = "forest nvim"

      dashboard.opts.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        mru_section(),
        dashboard.section.footer,
      }

      alpha.setup(dashboard.opts)
    end,
  },

  -- hex color preview
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = { names = false, rgb_fn = true },
      })
    end,
  },

  -- scrollbar
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("scrollbar").setup({
        handle = { color = "#e8a838" },
        marks = {
          Cursor = { color = "#d87756" },
          Error = { color = "#e5534b" },
          Warn = { color = "#e8c987" },
          Info = { color = "#9cc0ef" },
          Hint = { color = "#b79bd6" },
        },
      })
    end,
  },

  -- breadcrumbs (shown in lualine)
  {
    "SmiteshP/nvim-navic",
    event = "VeryLazy",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("nvim-navic").setup({
        highlight = true,
        separator = " › ",
        depth_limit = 5,
        lsp = { auto_attach = true },
      })
    end,
  },
}
