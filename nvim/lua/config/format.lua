return {
  setup = function()
    -- Voorkeursformatters; overige talen gebruiken lsp_format = 'fallback'.
    require('conform').setup({
      formatters_by_ft = {
        javascript = { 'prettierd' },
        json = { 'prettierd' },
        lua = { 'stylua' },
        markdown = { 'prettierd' },
        python = { 'ruff_organize_imports', 'ruff_format' },
        rust = { 'rustfmt' },
      },
      formatters = {
        rustfmt = {
          options = { default_edition = '2024' },
        },
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
