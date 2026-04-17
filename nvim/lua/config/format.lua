return {
  setup = function()
    require('conform').setup({
      formatters_by_ft = {
        javascript = { 'prettierd' },
        json = { 'prettierd' },
        lua = { 'stylua' },
        python = {
          'ruff_fix',
          'ruff_organize_imports',
          'ruff_format',
        },
      },
      format_on_save = function(bufnr)
        return {
          timeout_ms = 5000,
          lsp_format = vim.bo[bufnr].filetype == 'java' and 'fallback' or 'never',
        }
      end,
    })
  end,
}
