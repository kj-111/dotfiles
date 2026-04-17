vim.g.mapleader = ' '

vim.g.netrw_banner = 0
vim.g.netrw_hide = 0
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

function _G.statusline_lsp_icon() return #vim.lsp.get_clients({ bufnr = 0 }) > 0 and '󰰎 ' or '' end

vim.o.winborder = 'single'
vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-TermCursor'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 5
vim.opt.showmode = false
vim.opt.signcolumn = 'yes'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.rulerformat = '%{%v:lua.statusline_lsp_icon()%} %l|%L '

vim.opt.scrolloff = 10
vim.opt.wrap = false
vim.opt.smoothscroll = true

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

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
vim.opt.mouse = ''

vim.opt.undofile = true
