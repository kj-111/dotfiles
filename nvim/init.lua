-- Neovim Version: NVIM v0.12.5
-- macOS Version: 26.6.2

-- Filosofie: bewust minimaal en native

-- Toegangspoort voor de hele config; vanuit overal te openen met :e $MYVIMRC.

vim.loader.enable()

require('set')
require('config.neovide').setup()
require('autocmds')
require('remap')

require('config.session')
require('config.term').setup()

require('config.plugins').setup()
require('config.blink').setup()
require('config.format').setup()
require('config.mini').setup()
require('config.render_markdown').setup()
require('config.lsp').setup()
require('config.treesitter').setup()
