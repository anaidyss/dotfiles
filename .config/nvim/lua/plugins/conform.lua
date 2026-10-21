-- Conform: format on save. Formatters are installed by mason
-- (black/ruff, clang-format, stylua, shfmt) — conform finds them automatically.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    { "<leader>fm", function() require("conform").format({ async = true }) end, desc = "Format file" },
  },
  config = function()
    require("conform").setup({
      notify_on_error = true,
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback", -- if no formatter, format via LSP
      },
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        java = { "clang-format" },
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },
      -- clang-format handles Java/C/C++; pull a minimal style
      formatters = {
        clang_format = { prepend_args = { "--style", "{BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 100}" } },
      },
    })
  end,
}
