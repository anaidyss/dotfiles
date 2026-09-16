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
      -- palette matched to the forest theme: green #a6e3a1, teal #59c2a5, amber #e3c078
      palette_overrides = {
        dark0_hard = "#0f1512",
        dark0 = "#131a16",
        dark0_soft = "#17201b",
        dark1 = "#1a231e",
        dark2 = "#223029",
        dark3 = "#2c3f34",
        dark4 = "#3a4f42",

        light0_hard = "#eaf3ea",
        light0 = "#e0ece2",
        light0_soft = "#d7e3d9",
        light1 = "#cddbd0",
        light2 = "#b3c2b5",
        light3 = "#93a598",
        light4 = "#7a8c7f",

        gray = "#64766a",

        bright_red = "#d99a82",
        bright_green = "#a6e3a1",
        bright_yellow = "#e3c078",
        bright_blue = "#7fb8ad",
        bright_purple = "#c2a8cf",
        bright_aqua = "#6fd0b3",
        bright_orange = "#dca26a",

        neutral_red = "#c9745c",
        neutral_green = "#7cb87a",
        neutral_yellow = "#cfa95f",
        neutral_blue = "#5f9790",
        neutral_purple = "#a48bb5",
        neutral_aqua = "#59c2a5",
        neutral_orange = "#c68a52",

        faded_red = "#8a4f3d",
        faded_green = "#4e7a4f",
        faded_yellow = "#8a713c",
        faded_blue = "#3f6a64",
        faded_purple = "#6d5a7a",
        faded_aqua = "#33705f",
        faded_orange = "#855a35",

        dark_red_hard = "#4a2b22",
        dark_red = "#42271f",
        dark_red_soft = "#4d2f25",
        light_red_hard = "#e8b7a2",
        light_red = "#dfa892",
        light_red_soft = "#d99a82",

        dark_green_hard = "#2a4a2c",
        dark_green = "#264228",
        dark_green_soft = "#2d4f2f",
        light_green_hard = "#c8eac2",
        light_green = "#b8dcb2",
        light_green_soft = "#aad3a4",

        dark_aqua_hard = "#20483e",
        dark_aqua = "#1d4038",
        dark_aqua_soft = "#244d43",
        light_aqua_hard = "#bce8da",
        light_aqua = "#a8dccc",
        light_aqua_soft = "#99d0c0",
      },
      overrides = {},
      transparent_mode = true, -- transparent background
    })
    vim.cmd("colorscheme gruvbox")
  end,
}
