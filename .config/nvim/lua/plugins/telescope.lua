-- Telescope: fuzzy navigation across the project. The main search tool:
-- files, text, buffers, LSP symbols, git. fzf-native gives fast sorting.
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- needs gcc/make (present)
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files (C-p)" },
    { "<leader>g", "<cmd>Telescope live_grep<cr>", desc = "Grep text" },
    { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Open buffers" },
    { "<leader>h", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>s", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>S", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Project symbols" },
    { "<leader>F", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader>G", "<cmd>Telescope git_status<cr>", desc = "Git: changes" },
    { "<leader>C", "<cmd>Telescope commands<cr>", desc = "nvim commands" },
    { "<leader><leader>", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        file_ignore_patterns = { "node_modules", ".git/", "target/", "__pycache__", ".venv/" },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.smart_send_to_qflist,
            ["<Esc>"] = actions.close,
          },
        },
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55, width = 0.9, height = 0.85 },
          vertical = { mirror = false },
        },
        layout_strategy = "horizontal",
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
      pickers = {
        find_files = {
          hidden = true, -- show dotfiles
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--follow", "-E", ".git" },
        },
        live_grep = { additional_args = { "--hidden" } },
      },
    })

    -- attach the fzf sorter (silently, if not built yet)
    pcall(telescope.load_extension, "fzf")
  end,
}
