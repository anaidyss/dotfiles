-- Global keymaps. Plugin-specific mappings live in their own files
-- (lsp.lua, telescope.lua, neo-tree.lua). Here: pure editing and windows.

local map = vim.keymap.set

-- Quick exit from insert mode (vim-style)
map("i", "jk", "<ESC>", { desc = "Exit insert (jk)" })
map("i", "kj", "<ESC>", { desc = "Exit insert (kj)" })

-- Clear last search highlight on Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Move a selected block, keeping the selection after the shift
map("v", "<", "<gv", { desc = "Shift left (keep selection)" })
map("v", ">", ">gv", { desc = "Shift right (keep selection)" })

-- Window navigation with hjkl (like focus in niri)
map("n", "<C-h>", "<C-w>h", { desc = "Focus window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus window right" })

-- Resize windows with arrows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Window taller" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Window shorter" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Window narrower" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Window wider" })

-- Buffer switching (Shift+Tab forward, Ctrl+Shift+Tab backward)
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Close buffer without touching the window layout
map("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Save / quit
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>W", "<cmd>wa<CR>", { desc = "Save all" })
map("n", "<leader>Q", "<cmd>qa<CR>", { desc = "Quit nvim" })
