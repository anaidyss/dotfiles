-- Global editor options.
-- Everything follows the "forest" theme: minimal, readable, hjkl navigation
-- matching niri.

-- leader before anything else (plugins and which-key rely on Space)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Clipboard: copy/paste works with the system right away
opt.clipboard = "unnamedplus"

-- Line numbers: relative to the cursor, handy for 5j / 12k jumps
opt.number = true
opt.relativenumber = true

-- Indentation: 4 spaces (Python/Java), tabs become spaces
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true

-- Search: case-insensitive, smart switch when capitals are present
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor: highlight the current line so you don't get lost in long files
opt.cursorline = true
opt.cursorcolumn = false

-- Window splits: new window to the right/below (natural for hjkl)
opt.splitright = true
opt.splitbelow = true

-- Rendering: truecolor for kitty/gruvbox
opt.termguicolors = true
opt.signcolumn = "yes" -- persistent sign column so text doesn't jump
opt.scrolloff = 8 -- keep context around the cursor
opt.sidescrolloff = 8
opt.wrap = false -- don't wrap long lines (code reads horizontally)

-- Files: unix line endings, UTF-8
opt.fileencoding = "utf-8"
opt.fileformats = { "unix", "dos" }

-- Folding: treesitter syntax (see plugins/treesitter.lua)
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99 -- everything unfolded by default
opt.foldlevelstart = 99

-- Misc
opt.mouse = "a" -- mouse works in the terminal
opt.undofile = true -- undo history survives nvim restarts
opt.updatetime = 250
opt.timeoutlen = 400 -- leader combos fire without a long wait
opt.completeopt = { "menu", "menuone", "noselect" } -- nvim-cmp behavior
opt.showmode = false -- mode is shown in lualine, don't duplicate
opt.laststatus = 3 -- global statusline (cleaner for an IDE)
opt.pumheight = 10 -- completion menu height
opt.colorcolumn = "100" -- subtle line-width guide
