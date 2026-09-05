return {
  setup = function()
    require('render-markdown').setup({
      completions = { lsp = { enabled = true } },
      -- Uit: het beeld springt niet tijdens het typen. Nadeel is dat de ruwe
      -- [tekst](url) nergens te zien is, ook niet op de cursorregel.
      anti_conceal = { enabled = false },
      latex = { enabled = false },
      sign = { enabled = false },
    })

    vim.keymap.set('n', '<leader>v', '<cmd>RenderMarkdown toggle<CR>', { desc = 'Markdown-weergave aan/uit' })
  end,
}
