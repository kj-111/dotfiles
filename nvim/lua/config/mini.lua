local M = {}

-- mini.pick
local pick_win_config = function()
  local height = math.floor(0.618 * vim.o.lines)
  local width = math.floor(0.618 * vim.o.columns)

  return {
    anchor = 'NW',
    height = height,
    width = width,
    row = math.floor(0.3 * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end

local setup_pick = function()
  local pick = require('mini.pick')

  pick.setup({
    window = {
      config = pick_win_config,
    },
  })

  vim.keymap.set('n', '<leader>f', pick.builtin.files)
  vim.keymap.set('n', '<leader>j', pick.builtin.buffers)
end

-- mini.clue
local setup_clue = function()
  local miniclue = require('mini.clue')

  miniclue.setup({
    clues = {
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = { 'n', 'x' }, keys = '<Leader>' },
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = ']' },
      { mode = 'i', keys = '<C-x>' },
      { mode = { 'n', 'x' }, keys = 'g' },
      { mode = { 'n', 'x' }, keys = "'" },
      { mode = { 'n', 'x' }, keys = '`' },
      { mode = { 'n', 'x' }, keys = '"' },
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' },
      { mode = { 'n', 'x' }, keys = 'z' },
    },
  })
end

-- miniharp
local setup_miniharp = function()
  local miniharp = require('miniharp')

  miniharp.setup()

  vim.keymap.set('n', '<leader>m', miniharp.toggle_file)
  vim.keymap.set('n', '<C-j>', miniharp.next)
  vim.keymap.set('n', '<C-k>', miniharp.prev)
  vim.keymap.set('n', '<leader>l', miniharp.show_list)
end

-- setup
function M.setup()
  require('mini.pairs').setup()
  setup_pick()
  setup_miniharp()
  setup_clue()
end

return M
