-- Lualine: statusline in the forest theme. The "gruvbox" theme is already
-- recolored to the forest palette (see gruvbox.lua), so colors are automatic.
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "gruvbox",
        globalstatus = true, -- one line for the whole window (laststatus=3)
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "dashboard", "neo-tree" } },
      },
      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = { { "branch", icon = "" }, "diff" },
        lualine_c = {
          { "diagnostics", sources = { "nvim_diagnostic" }, symbols = { error = "✘ ", warn = "▲ ", info = "ℹ ", hint = "⚡ " } },
          { "filename", path = 1 }, -- relative path
        },
        lualine_x = { "encoding", { "fileformat", symbols = { unix = "LF", dos = "CRLF", mac = "CR" } }, { "filetype", icon_only = false } },
        lualine_y = { "location", "progress" },
        lualine_z = { { "tabs", mode = 1 } },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}
