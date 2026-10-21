-- Gitsigns: git-change marks to the left of lines + hunk navigation.
-- Added — green, modified — amber, deleted — terra.
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "▌", hl = "GitSignsAdd" },
        change = { text = "▌", hl = "GitSignsChange" },
        delete = { text = "▁", hl = "GitSignsDelete" },
        topdelete = { text = "▔", hl = "GitSignsDelete" },
        changedelete = { text = "▌", hl = "GitSignsChange" },
        untracked = { text = "┊", hl = "GitSignsAdd" },
      },
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, keys, fn, desc)
          vim.keymap.set(mode, keys, fn, { buffer = bufnr, desc = "Git: " .. desc })
        end
        map("n", "]h", gs.next_hunk, "next hunk")
        map("n", "[h", gs.prev_hunk, "previous hunk")
        map("n", "<leader>gp", gs.preview_hunk, "preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "blame line")
        map("n", "<leader>hs", gs.stage_hunk, "stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "reset hunk")
      end,
    })

    -- forest colors for the signs
    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#a6e3a1" })
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e3c078" })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#c9745c" })
  end,
}
