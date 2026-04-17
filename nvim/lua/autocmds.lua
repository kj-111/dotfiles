local misc = vim.api.nvim_create_augroup('misc', { clear = true })
local checktime = vim.api.nvim_create_augroup('checktime', { clear = true })
local close_with_q = vim.api.nvim_create_augroup('close-with-q', { clear = true })
local help_window = vim.api.nvim_create_augroup('help-window', { clear = true })
local highlight_yank = vim.api.nvim_create_augroup('highlight-yank', { clear = true })
local netrw_setup = vim.api.nvim_create_augroup('netrw-setup', { clear = true })
local filetype_setup = vim.api.nvim_create_augroup('filetype-setup', { clear = true })
local scroll_eof = vim.api.nvim_create_augroup('scroll-eof', { clear = true })
local terminal_setup = vim.api.nvim_create_augroup('terminal-setup', { clear = true })
local pdf = vim.api.nvim_create_augroup('pdf-open', { clear = true })

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open file at the last position it was edited earlier',
  group = misc,
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  desc = 'Reload files changed outside Neovim',
  group = checktime,
  command = 'checktime',
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Open help buffers in a vertical split',
  group = help_window,
  pattern = 'help',
  callback = function()
    vim.cmd.wincmd('L')
    vim.cmd('vertical resize 80')
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = highlight_yank,
  callback = function() vim.hl.on_yank({ higroup = 'YankHighlight' }) end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Hide terminal buffers from buffer lists',
  group = terminal_setup,
  callback = function() vim.opt_local.buflisted = false end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close utility buffers with q',
  group = close_with_q,
  pattern = { 'help', 'qf', 'man', 'checkhealth' },
  callback = function(event) vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true }) end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Configure netrw buffer keymaps and local options',
  group = netrw_setup,
  pattern = 'netrw',
  callback = function(event)
    vim.keymap.set('n', 'h', '-', { buffer = event.buf, remap = true, silent = true })
    vim.keymap.set('n', 'l', '<CR>', { buffer = event.buf, remap = true, silent = true })
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Use two-space indentation for Lua files',
  group = filetype_setup,
  pattern = 'lua',
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Enable wrapped visual navigation for Markdown files',
  group = filetype_setup,
  pattern = 'markdown',
  callback = function(args)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true

    -- vim.keymap.set('i', 'jk', 'jk', { buffer = args.buf })
    vim.keymap.set('n', 'j', 'gj', { buffer = args.buf })
    vim.keymap.set('n', 'k', 'gk', { buffer = args.buf })
  end,
})

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'WinScrolled' }, {
  group = scroll_eof,
  desc = 'Keep scrolloff context near the end of the file',
  callback = function()
    if vim.api.nvim_win_get_config(0).relative ~= '' then return end
    if vim.bo.buftype ~= '' then return end

    local win_height = vim.fn.winheight(0)
    local scrolloff = math.min(vim.o.scrolloff, math.floor(win_height / 2))
    local distance_to_eof = win_height - vim.fn.winline()

    if distance_to_eof < scrolloff then
      local view = vim.fn.winsaveview()
      view.topline = view.topline + scrolloff - distance_to_eof
      vim.fn.winrestview(view)
    end
  end,
})

vim.api.nvim_create_autocmd('BufReadCmd', {
  desc = 'Open PDF files in Sioyek instead of editing them',
  group = pdf,
  pattern = '*.pdf',
  callback = function()
    local filename = vim.fn.shellescape(vim.api.nvim_buf_get_name(0))
    vim.cmd('silent! !open -a Sioyek ' .. filename .. ' &')
    vim.cmd('bd!')
  end,
})
