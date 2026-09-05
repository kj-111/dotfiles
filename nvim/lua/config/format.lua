return {
  setup = function()
    -- Alleen talen zonder sterke LSP-formatter; de rest doet lsp_format = 'fallback'.
    require('conform').setup({
      formatters_by_ft = {
        javascript = { 'prettierd' },
        json = { 'prettierd' },
        lua = { 'stylua' },
        markdown = { 'prettierd' },
        python = { 'ruff_organize_imports', 'ruff_format' },
      },
      -- Java niet hier: jdtls formatteert via de fallback, met de
      -- projectinstellingen uit .settings/org.eclipse.jdt.core.prefs.
      format_on_save = {
        timeout_ms = 5000,
        lsp_format = 'fallback',
      },
    })
  end,
}
