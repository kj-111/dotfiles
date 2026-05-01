local M = {}

-- mini.pick
local pick_win_config = function()
  local height = math.floor(0.618 * vim.o.lines)
  local width = math.floor(0.618 * vim.o.columns)

  return {
    anchor = 'NW',
    height = height,
    width = width,
    row = math.floor(0.5 * (vim.o.lines - height)),
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

-- setup
function M.setup()
  require('mini.pairs').setup()
  setup_pick()
end

return M
