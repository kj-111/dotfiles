--- Elk bestand in lsp/ is één server.
-- Only enable our own native configs. nvim-jdtls also ships lsp/jdtls.lua,
-- but Java is started manually through config.jdtls to keep its workspace setup.
local function configured_servers()
  local servers = {}
  local lsp_dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'lsp')

  for name, type in vim.fs.dir(lsp_dir) do
    if type == 'file' and name:match('%.lua$') then
      local server = name:gsub('%.lua$', '')
      table.insert(servers, server)
    end
  end

  table.sort(servers)
  return servers
end

local function client_capabilities()
  local capabilities = require('blink.cmp').get_lsp_capabilities()

  -- Neovim's recursieve macOS-watcher kan bij dynamische LSP-registraties
  -- EMFILE raken. Buffers blijven normaal synchroniseren; herstart de LSP na
  -- externe projectwijzigingen (neovim/neovim#40238).
  capabilities.workspace = capabilities.workspace or {}
  capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }

  return capabilities
end

local function setup_server_defaults(capabilities) vim.lsp.config('*', { capabilities = capabilities }) end

local function setup_diagnostics()
  vim.diagnostic.config({
    virtual_text = false,
    underline = false,
    severity_sort = true,
    float = { source = 'if_many' },
  })
end

-- De features die nvim default uit laat (:h lsp-quickstart, punt 6), hier
-- expliciet op die default (lsp.md).
local function setup_optional_features()
  vim.lsp.inlay_hint.enable(false)
  vim.lsp.codelens.enable(false)
  vim.lsp.linked_editing_range.enable(false)
  vim.lsp.inline_completion.enable(false)
  vim.lsp.on_type_formatting.enable(false)

  vim.api.nvim_create_user_command(
    'InlayHints',
    function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
    { desc = 'Inlay hints globaal aan/uit' }
  )
end

return {
  setup = function()
    local capabilities = client_capabilities()

    setup_server_defaults(capabilities)
    setup_diagnostics()
    setup_optional_features()
    require('config.jdtls').setup(capabilities)
    vim.lsp.enable(configured_servers())
  end,
}
