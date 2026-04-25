local state = { buf = -1, win = -1 }

local function reset_state()
  state.buf = -1
  state.win = -1
end

local function clear_terminal_buffer()
  if vim.api.nvim_buf_is_valid(state.buf) then vim.api.nvim_buf_delete(state.buf, { force = true }) end

  reset_state()
end

local function ensure_terminal_buffer()
  if vim.api.nvim_buf_is_valid(state.buf) and vim.bo[state.buf].buftype == 'terminal' then return end

  state.buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_call(state.buf, function() vim.cmd.terminal() end)

  vim.bo[state.buf].buflisted = false

  vim.api.nvim_create_autocmd('TermClose', {
    buffer = state.buf,
    once = true,
    callback = clear_terminal_buffer,
  })
end

local function open_window()
  local height = vim.o.lines

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = 'editor',
    width = vim.o.columns,
    height = height,
    col = 0,
    row = 0,
    style = 'minimal',
  })

  vim.cmd.startinsert()
end

local function toggle()
  if vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_hide(state.win)
    state.win = -1
    return
  end

  ensure_terminal_buffer()
  open_window()
end

return {
  setup = function()
    vim.keymap.set('n', '<C-f>', toggle)
    vim.keymap.set('t', '<C-f>', function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 't', false)
      vim.schedule(toggle)
    end)

    vim.api.nvim_create_autocmd('SessionLoadPost', {
      group = vim.api.nvim_create_augroup('floating-terminal-session', { clear = true }),
      callback = clear_terminal_buffer,
    })
  end,
  toggle = toggle,
}
