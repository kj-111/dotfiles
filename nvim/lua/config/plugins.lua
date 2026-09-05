-- Pin-beleid: de lockfile (nvim-pack-lock.json) legt élke plugin op een exacte
-- commit vast; alleen een bewuste vim.pack.update() verzet ze. Na een update
-- ook herstarten en :TSUpdate draaien: treesitter-parsers hebben eigen revisies.
local plugins = {
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1.10.2' },
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/mfussenegger/nvim-jdtls' },
  { src = 'https://github.com/nvim-mini/mini.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
}

return {
  setup = function()
    vim.pack.add(plugins)
    vim.cmd('packadd nvim.undotree')
  end,
}
