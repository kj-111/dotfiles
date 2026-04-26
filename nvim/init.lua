vim.loader.enable()

require('vim._core.ui2').enable({})

vim.cmd.colorscheme('nord')

require('set')
require('config.neovide').setup()
require('autocmds')
require('remap')

vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1.10.2' },
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mfussenegger/nvim-jdtls',
  'https://github.com/nvim-mini/mini.clue',
  'https://github.com/nvim-mini/mini.pairs',
  'https://github.com/nvim-mini/mini.pick',
  'git@github.com:kj-111/miniharp.nvim.git',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'git@github.com:kj-111/dodona.nvim.git',
  'https://github.com/OXY2DEV/markview.nvim',
})

vim.cmd('packadd nvim.undotree')

require('markview').setup()
require('config.term').setup()
require('config.mason').setup()
require('config.treesitter').setup()
require('config.mini').setup()
require('config.blink').setup()
require('config.format').setup()
require('config.java_new').setup()
require('config.jdtls').setup()
require('config.lsp').setup()
require('dodona').setup()
