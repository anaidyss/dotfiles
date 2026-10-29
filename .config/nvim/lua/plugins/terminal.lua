-- Terminal & misc: toggleterm (floating terminal), ufo (better folding),
-- markdown preview.

-- Build & run the current C file inside a floating terminal (<leader>r).
-- The callback lives inside the toggleterm spec so lazy.nvim loads (and
-- configures) toggleterm before <leader>r fires — require() then hits the
-- setup instance.
local function run_c()
  local ext = vim.fn.expand("%:e")
  if ext ~= "c" then
    vim.notify("Not a C file: " .. vim.fn.expand("%:t"), vim.log.levels.WARN)
    return
  end
  local src = vim.fn.expand("%:p")
  local out = vim.fn.expand("%:p:r")
  local cmd = string.format('gcc -Wall -Wextra -g -std=c11 "%s" -o "%s" && "%s"', src, out, out)
  require("toggleterm").exec(cmd, nil, nil, nil, "float")
end

return {
  -- floating terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Floating terminal" },
      { "<leader>r", run_c, desc = "Build & run C file" },
    },
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<C-\>]],
        direction = "float",
        float_opts = {
          border = "curved",
          winblend = 0,
        },
        highlights = {
          Normal = { link = "Normal" },
          NormalFloat = { link = "NormalFloat" },
          FloatBorder = { guifg = "#e8a838" },
        },
      })
    end,
  },

  -- better folding (ufo)
  {
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "v:lua.require'ufo'.foldexpr()"
      require("ufo").setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
    end,
  },

  -- markdown preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" },
    },
  },
}
