vim.g.mapleader = ' '

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Netrw uit, vóór het plugin-laden: mini.files is de verkenner.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

pcall(function() require('vim._core.ui2').enable({}) end)
vim.cmd.colorscheme('nord')

vim.opt.winborder = 'single'
-- De cursorvorm maakt de actieve mode direct zichtbaar.
vim.opt.guicursor = 'n-v-c-sm:block,i-ci-ve:ver35,r-cr-o:hor20,t:ver35-TermCursor'

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
vim.opt.laststatus = 3
vim.opt.cmdheight = 1
vim.opt.showmode = false
vim.opt.shortmess:append('IWs')
vim.opt.signcolumn = 'yes'
vim.opt.splitright = true
vim.opt.splitbelow = true

_G.Config = {
  -- Sessie-icoon zodra een sessie gemaakt of hersteld is.
  statusline_session_icon = function() return vim.v.this_session ~= '' and '󰆓 ' or '' end,
  -- Lsp-icoon zodra er een client aan de buffer hangt (afwezigheid = uit).
  statusline_lsp_icon = function() return next(vim.lsp.get_clients({ bufnr = 0 })) and '󰰎 ' or '' end,
}
-- %l tekent zelf de nummerkolom volgens 'number'/'relativenumber'.
vim.opt.statuscolumn = '%s%=%l %C '
vim.opt.statusline =
  ' %f %h%m%r %= %{%v:lua.Config.statusline_session_icon()%}%{%v:lua.Config.statusline_lsp_icon()%} %l:%c | %L '

vim.opt.scrolloff = 10
vim.opt.scroll = 8
vim.opt.wrap = false
vim.opt.smoothscroll = true

vim.opt.foldlevel = 99
-- vim.opt.foldlevelstart = 99 -- reset foldlevel bij elke nieuwe buffer, dus zM
-- verdween weer zodra je van bestand wisselde; default -1 laat het staan

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.confirm = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

vim.opt.updatetime = 200
vim.opt.timeoutlen = 300

vim.opt.virtualedit = 'block'
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', leadmultispace = '│   ' }
vim.opt.mouse = 'a'
vim.opt.mousescroll = 'ver:3,hor:0'

vim.opt.undofile = true

-- Wat :mksession bewaart, op de nvim-default gezet. Bewust géén 'options':
-- init.lua zet die toch weer, en opgeslagen waarden botsen daarmee.
vim.opt.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,terminal'

-- Cmdline: fuzzy completion in een popup, en rg achter :grep.
vim.opt.wildmode = 'noselect:lastused,full'
vim.opt.wildoptions = 'pum,tagfile,fuzzy'
vim.opt.pumheight = 5
vim.opt.pumborder = 'single'
vim.opt.grepprg = 'rg --vimgrep --smart-case'
vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
