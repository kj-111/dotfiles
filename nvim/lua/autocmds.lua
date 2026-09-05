local group = vim.api.nvim_create_augroup('user-autocmds', { clear = true })

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open file at the last position it was edited earlier',
  group = group,
  callback = function(ev)
    -- Alleen bij de eerste lezing: een herlezing (:edit, of :argument naar het
    -- bestand waar je al in zit) bewaart de cursor zelf al, en dan zou de zv
    -- enkel de fold eronder openzetten
    if vim.b[ev.buf].last_pos_restored then return end
    vim.b[ev.buf].last_pos_restored = true
    vim.cmd('silent! normal! g`"zv')
  end,
})

vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  desc = 'Open the quickfix window after :make/:grep',
  group = group,
  pattern = '[^l]*',
  nested = true,
  command = 'cwindow',
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close utility buffers with q',
  group = group,
  pattern = { 'git', 'help', 'man', 'qf', 'scratch' },
  callback = function(args)
    if args.match == 'help' and vim.bo[args.buf].modifiable then return end
    if vim.fn.maparg('q', 'n') ~= '' then return end

    vim.keymap.set('n', 'q', '<cmd>quit<CR>', {
      buffer = args.buf,
      desc = 'Close window',
      silent = true,
    })
  end,
})

-- TermOpen dekt een verse terminal, BufEnter het terugkomen en :b term.
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
  desc = 'Start insert mode when entering a terminal',
  group = group,
  callback = function()
    if vim.bo.buftype == 'terminal' then vim.cmd.startinsert() end
  end,
})

vim.api.nvim_create_autocmd('CmdlineChanged', {
  desc = 'Show completion matches while typing',
  group = group,
  pattern = { ':', '/', '\\?' },
  callback = function(args)
    if vim.fn.win_gettype() == 'command' then return end
    if args.match == ':' and not vim.fn.getcmdline():find(' ') then return end

    vim.fn.wildtrigger()
  end,
})

vim.api.nvim_create_autocmd('BufReadCmd', {
  desc = 'Open a PDF or video in an external app instead of the buffer',
  group = group,
  pattern = { '*.pdf', '*.mp4' },
  callback = function(ev)
    local file = vim.fn.fnamemodify(ev.file, ':p')
    local cmd = file:lower():match('%.pdf$') and { 'open', '-a', 'Sioyek', file } or { 'open', file }
    vim.system(cmd, { text = true }, function(res)
      if res.code ~= 0 then vim.schedule(function() vim.notify(vim.trim(res.stderr), vim.log.levels.ERROR) end) end
    end)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then vim.api.nvim_buf_delete(ev.buf, { force = true }) end
    end)
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = group,
  callback = function() vim.hl.on_yank({ higroup = 'YankHighlight' }) end,
})

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  group = group,
  desc = 'Keep scrolloff context near the end of the file',
  callback = function()
    if vim.api.nvim_win_get_config(0).relative ~= '' or vim.bo.buftype ~= '' then return end

    local win_height = vim.api.nvim_win_get_height(0)
    local scrolloff = math.min(vim.o.scrolloff, math.floor(win_height / 2))
    local winline = vim.fn.winline()
    local distance_to_eof = win_height - winline

    if distance_to_eof < scrolloff then
      local view = vim.fn.winsaveview()
      view.topline = view.topline + scrolloff - distance_to_eof
      vim.fn.winrestview(view)
    end
  end,
})
