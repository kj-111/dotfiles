return {
  setup = function()
    vim.lsp.config('*', {
      capabilities = require('blink.cmp').get_lsp_capabilities(),
    })

    vim.lsp.enable({ 'basedpyright', 'clangd', 'lua_ls', 'ruff', 'ts_ls' })

    vim.diagnostic.config({
      virtual_text = false,
      underline = false,
      severity_sort = true,
    })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client.name == 'ruff' then client.server_capabilities.hoverProvider = false end

        if
          client
          and vim.tbl_contains({ 'basedpyright', 'ts_ls' }, client.name)
          and client:supports_method('textDocument/inlayHint')
        then
          vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
        end
      end,
    })

    vim.api.nvim_create_autocmd({ 'LspAttach', 'LspDetach' }, {
      group = vim.api.nvim_create_augroup('lsp-statusline', { clear = true }),
      callback = function() vim.cmd.redrawstatus() end,
    })
  end,
}
