-- Bufferline: a row of tabs at the top. All open buffers are visible, switch
-- by number (like niri workspaces Mod+1..9). Colors matched to forest.
return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Buffer 1" },
    { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Buffer 2" },
    { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Buffer 3" },
    { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Buffer 4" },
    { "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Buffer 5" },
    { "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Buffer 6" },
    { "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Buffer 7" },
    { "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Buffer 8" },
    { "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Buffer 9" },
  },
  config = function()
    require("bufferline").setup({
      options = {
        numbers = "ordinal", -- tab numbers for <leader>1..9
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "neo-tree", text = "Explorer", highlight = "NeoTreeRootName", separator = true },
        },
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = "slant",
        always_show_bufferline = true,
      },
      -- forest palette for active/inactive tabs
      highlights = {
        fill = { bg = { highlight = "Normal" } },
        background = { bg = "#131a16", fg = "#93a598" },
        buffer_visible = { bg = "#131a16", fg = "#cddbd0" },
        buffer_selected = { bg = "#1a231e", fg = "#a6e3a1", bold = true, italic = false },
        tab_selected = { bg = "#1a231e", fg = "#a6e3a1" },
        indicator_selected = { fg = "#a6e3a1", bg = "#1a231e" },
        separator_selected = { fg = "#131a16", bg = "#1a231e" },
        separator_visible = { fg = "#131a16", bg = "#131a16" },
        separator = { fg = "#131a16", bg = "#131a16" },
        diagnostic_selected = { fg = "#e3c078" },
        error_selected = { fg = "#c9745c" },
        warning_selected = { fg = "#e3c078" },
      },
    })
  end,
}
