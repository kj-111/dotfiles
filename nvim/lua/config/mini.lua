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
  vim.keymap.set('n', '<leader>h', pick.builtin.help)
  vim.keymap.set('n', '<leader>j', pick.builtin.buffers)
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
end

return M
