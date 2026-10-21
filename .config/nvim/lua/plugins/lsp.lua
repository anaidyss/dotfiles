-- LSP: mason installs servers, mason-lspconfig wires them into the built-in
-- vim.lsp (nvim 0.11+). Java is separate via nvim-jdtls (ftplugin/java.lua),
-- because jdtls needs its own workspace and a launch per opened .java file.

-- on_attach: local LSP keys + inlay hints (clangd/pyright/ruff)
local function on_attach(client, bufnr)
  local map = function(keys, fn, desc)
    vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = "LSP: " .. desc })
  end

  map("gd", vim.lsp.buf.definition, "go to definition")
  map("gD", vim.lsp.buf.declaration, "go to declaration")
  map("gr", vim.lsp.buf.references, "references")
  map("gi", vim.lsp.buf.implementation, "go to implementation")
  map("K", vim.lsp.buf.hover, "hover docs")
  map("<leader>rn", vim.lsp.buf.rename, "rename symbol")
  map("<leader>ca", vim.lsp.buf.code_action, "code action")
  map("<leader>D", vim.lsp.buf.type_definition, "type definition")
  map("[d", vim.diagnostic.goto_prev, "previous diagnostic")
  map("]d", vim.diagnostic.goto_next, "next diagnostic")
  map("<leader>d", vim.diagnostic.open_float, "diagnostic under cursor")

  -- inlay hints: type/parameter-name hints inline
  if client.supports_method and client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

-- Diagnostic signs in the forest palette: error — terra, warning — amber
vim.fn.sign_define("DiagnosticSignError", { text = "✘", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "▲", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "ℹ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "⚡", texthl = "DiagnosticSignHint" })

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

return {
  -- installer for servers/formatters
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = { package_installed = "●", package_pending = "○", package_uninstalled = "✖" },
        },
      })

      -- install tools that are NOT lspconfig servers:
      -- jdtls (own launch), formatters and linters.
      local registry = require("mason-registry")
      local tools = { "jdtls", "clang-format", "stylua", "black", "shfmt" }
      local function ensure()
        for _, name in ipairs(tools) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end
      if registry.refresh then
        registry.refresh(ensure)
      else
        ensure()
      end
    end,
  },

  -- mason → vim.lsp bridge (auto-connect servers)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig", "williamboman/mason.nvim" },
    config = function()
      -- client capabilities: add what nvim-cmp provides (extra completion context)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- global config for all servers
      vim.lsp.config("*", {
        capabilities = capabilities,
        on_attach = on_attach,
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "basedpyright", -- Python (fast, typed)
          "ruff", -- Python: linter + formatter
          "clangd", -- C / C++
          "lua_ls", -- Lua (nvim configs)
          "bashls", -- bash / sh scripts
          "yamlls", -- YAML
        },
        automatic_enable = true, -- nvim 0.11+: connects via vim.lsp.enable
      })

      -- per-server tweaks
      vim.lsp.config("clangd", {
        cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
            },
          },
        },
      })

      vim.lsp.config("ruff", {
        init_options = { settings = { args = {} } },
        on_attach = function(client, bufnr)
          -- ruff only handles lint/format; hover comes from pyright
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
          on_attach(client, bufnr)
        end,
      })
    end,
  },

  -- Java: full jdtls client (launched when a *.java file opens)
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "williamboman/mason.nvim" },
  },
}
