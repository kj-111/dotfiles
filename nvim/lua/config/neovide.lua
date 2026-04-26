local M = {}

function M.setup()
  if not vim.g.neovide then return end

  vim.g.neovide_opacity = 0.999
  vim.g.neovide_normal_opacity = 1.0
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_left = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_window_blurred = false
  vim.g.neovide_floating_blur_amount_x = 0.0
  vim.g.neovide_floating_blur_amount_y = 0.0
  vim.g.neovide_floating_shadow = false
  vim.g.neovide_floating_corner_radius = 0.0
  vim.g.neovide_show_border = false

  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_theme = 'dark'
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_cursor_vfx_mode = ''

  vim.o.guicursor =
    'n-v-c-sm:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr-o:hor20-Cursor/lCursor,t:block-TermCursor'

  local function change_scale(delta)
    local scale = vim.g.neovide_scale_factor + delta
    vim.g.neovide_scale_factor = math.max(0.5, math.min(2.0, scale))
  end

  vim.keymap.set({ 'n', 'i', 'v', 'c', 't' }, '<D-k>', function() change_scale(0.1) end, { silent = true })
  vim.keymap.set({ 'n', 'i', 'v', 'c', 't' }, '<D-j>', function() change_scale(-0.1) end, { silent = true })

  vim.keymap.set('v', '<D-c>', '"+y', { silent = true })
  vim.keymap.set('n', '<D-v>', '"+p', { silent = true })
  vim.keymap.set('v', '<D-v>', '"+p', { silent = true })
  vim.keymap.set({ 'i', 'c' }, '<D-v>', '<C-r>+', { silent = true })
  vim.keymap.set('t', '<D-v>', function()
    local job = vim.b.terminal_job_id
    if job then vim.api.nvim_chan_send(job, vim.fn.getreg('+')) end
  end, { silent = true })

  for _, key in ipairs({ 'q', 'w', 'n', 'm', 'h', 'f', '[', ']', 's' }) do
    vim.keymap.set({ 'n', 'i', 'v', 'c', 't' }, '<D-' .. key .. '>', '<Nop>', { silent = true })
  end
end

return M
