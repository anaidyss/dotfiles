return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  config = function()
    require("gruvbox").setup({
      terminal_colors = true,
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        operators = false,
        comments = true,
        folds = true,
        loops = false,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = "soft",
      -- palette matched to the forest theme: green #d87756, teal #e8a838, amber #e8c987
      palette_overrides = {
        dark0_hard = "#1a1b19",
        dark0 = "#1e1f1c",
        dark0_soft = "#262725",
        dark1 = "#2a2a28",
        dark2 = "#30302e",
        dark3 = "#3c3c3a",
        dark4 = "#484845",

        light0_hard = "#f3f3f1",
        light0 = "#eaeae8",
        light0_soft = "#dcdcda",
        light1 = "#d5d5d3",
        light2 = "#b5b5b2",
        light3 = "#9a9a98",
        light4 = "#85857f",

        gray = "#73736f",

        bright_red = "#f07a72",
        bright_green = "#d87756",
        bright_yellow = "#e8c987",
        bright_blue = "#9cc0ef",
        bright_purple = "#d3bcee",
        bright_aqua = "#8eeaea",
        bright_orange = "#e8a050",

        neutral_red = "#e5534b",
        neutral_green = "#78b4c0",
        neutral_yellow = "#d4a24c",
        neutral_blue = "#6f98cc",
        neutral_purple = "#b79bd6",
        neutral_aqua = "#e8a838",
        neutral_orange = "#d08a40",

        faded_red = "#8a3a36",
        faded_green = "#4f8590",
        faded_yellow = "#8a6a2c",
        faded_blue = "#4a78a8",
        faded_purple = "#6f5f8f",
        faded_aqua = "#3a6a9e",
        faded_orange = "#8a5424",

        dark_red_hard = "#4a2423",
        dark_red = "#421f1f",
        dark_red_soft = "#4d2626",
        light_red_hard = "#f4aaa4",
        light_red = "#f2928b",
        light_red_soft = "#f07a72",

        dark_green_hard = "#25454d",
        dark_green = "#23404a",
        dark_green_soft = "#2a4f58",
        light_green_hard = "#f4b8a0",
        light_green = "#ecae92",
        light_green_soft = "#e89273",

        dark_aqua_hard = "#203d5c",
        dark_aqua = "#1d3550",
        dark_aqua_soft = "#24456b",
        light_aqua_hard = "#d2e6f8",
        light_aqua = "#c0daf4",
        light_aqua_soft = "#a8c8ee",
      },
      overrides = {},
      transparent_mode = false, -- solid background, so nvim reads as an app window
    })
    vim.cmd("colorscheme gruvbox")

    -- soft cursorline: a subtle forest tint under the current line
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2a2a28" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#d87756", bold = true })
  end,
}
