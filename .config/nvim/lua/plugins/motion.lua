-- Motion & navigation: flash (fast jump), surround.
return {
  -- fast jump to any location
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
    config = function()
      require("flash").setup({
        labels = "asdfghjklqwertyuiopzxcvbnm",
        highlight = { backdrop = false },
      })
    end,
  },

  -- surround text objects (ys/ cs/ ds)
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
}
