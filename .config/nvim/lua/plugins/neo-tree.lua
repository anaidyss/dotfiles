-- Neo-tree: side project tree. Open with <leader>e, focus/navigate with hjkl.
-- Colors are matched to the forest palette (green/teal/amber/terra).
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File tree (Neo-tree)" },
    { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in tree" },
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      sort_case_insensitive = true,
      default_component_configs = {
        indent = { indent_size = 2, padding = 1, with_markers = true },
        icon = { folder_closed = "", folder_open = "", folder_empty = "", default = "󰈙" },
        name = { trailing_slash = false, use_git_status_colors = true, highlight = "NeoTreeFileName" },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "★",
            ignored = "",
            unstaged = "U",
            staged = "",
            conflict = "!",
          },
        },
      },
      window = {
        position = "left",
        width = 32,
        mappings = {
          ["<space>"] = "none", -- don't hijack the leader inside the tree
          ["h"] = "close_node",
          ["l"] = "open",
          ["<CR>"] = "open",
          ["o"] = "open",
          ["a"] = "add",
          ["d"] = "delete",
          ["r"] = "rename",
          ["x"] = "cut_to_clipboard",
          ["c"] = "copy_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["R"] = "refresh",
          ["?"] = "show_help",
        },
      },
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false, -- show hidden files (configs matter)
          hide_gitignored = false,
          never_show = { ".git" },
        },
        follow_current_file = { enabled = true },
        group_empty_dirs = true,
        use_libuv_file_watcher = true,
      },
      git_status = { window = { position = "float" } },
      -- forest colors for git statuses and diagnostics
      highlight_groups = {},
    })

    -- coloring: directories — teal, executables/modified — amber, deletions — terra
    vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { fg = "#e8a838" })
    vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { fg = "#9cc0ef", bold = true })
    vim.api.nvim_set_hl(0, "NeoTreeRootName", { fg = "#d87756", bold = true })
    vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#e8c987" })
    vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = "#d87756" })
    vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = "#e5534b" })
vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#8eeaea" })
    vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", { fg = "#73736f" })

    -- auto-open the tree on startup (IDE-style), unless a single file was passed
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv()[1]) == 1 then
          vim.cmd("Neotree")
        end
      end,
    })
  end,
}
