-- jdtls startup for Java files. jdtls is not a regular LSP: it needs its own
-- workspace-data directory and a manual launch per open project, so it is kept
-- separate from mason-lspconfig and lives in ftplugin (runs for *.java).

local ok, jdtls = pcall(require, "jdtls")
if not ok then
  return
end

-- jdtls may not be downloaded via mason yet — don't break nvim
local reg_ok, registry = pcall(require, "mason-registry")
if not reg_ok then
  return
end
local pkg_ok, pkg = pcall(registry.get_package, "jdtls")
if not pkg_ok or not pkg:is_installed() then
  vim.notify("jdtls is not installed. Open :Mason and install jdtls.", vim.log.levels.WARN)
  return
end

local jdtls_path = pkg:get_install_path()

-- find the project root (maven/gradle/git/eclipse)
local root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", ".git", ".project" }
local root_dir = vim.fs.root(0, root_markers) or vim.fn.getcwd()

-- a separate data directory per project, otherwise jdtls mixes projects up
local workspace = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root_dir, ":t")

-- on_attach: same LSP keys as other servers + Java specifics
local function on_attach(client, bufnr)
  local map = function(keys, fn, desc)
    vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = "LSP: " .. desc })
  end
  map("gd", vim.lsp.buf.definition, "go to definition")
  map("gr", vim.lsp.buf.references, "references")
  map("K", vim.lsp.buf.hover, "hover docs")
  map("<leader>rn", vim.lsp.buf.rename, "rename symbol")
  map("<leader>ca", vim.lsp.buf.code_action, "code action")
  map("<leader>o", jdtls.organize_imports, "organize imports")
  map("[d", vim.diagnostic.goto_prev, "previous diagnostic")
  map("]d", vim.diagnostic.goto_next, "next diagnostic")

  if client.supports_method and client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

-- client capabilities (nvim-cmp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

local config = {
  cmd = {
    vim.fn.exepath("java"), -- full path to java (already in the system)
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.default=org.eclipse.jdt.ls.core",
    "-Dlog.level=ALL",
    "-Xmx2G",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration", jdtls_path .. "/config_linux",
    "-data", workspace,
  },
  root_dir = root_dir,
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      completion = { favoriteStaticMembers = { "org.junit.Assert.*", "org.junit.jupiter.api.Assertions.*" } },
      configuration = { updateBuildConfiguration = "interactive" },
      referencesCodeLens = { enabled = true },
      implementationsCodeLens = { enabled = true },
      inlayHints = { parameterNames = { enabled = "all" } },
    },
  },
}

-- start_or_attach reuses the client if a file from the same project is open
jdtls.start_or_attach(config)
