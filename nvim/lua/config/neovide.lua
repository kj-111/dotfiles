local M = {}

function M.setup()
  if not vim.g.neovide then return end

  -- Samen de vensterschaduw uit: setHasShadow(opaque || show_border), dus net
  -- onder 1.0 én geen border. Kost alpha 0.999 op de achtergrond.
  vim.g.neovide_opacity = 0.999
  vim.g.neovide_show_border = false
  -- "you can use a gamma of 0.8 and a contrast of 0.1" om Alacritty te emuleren
  -- (neovide.dev/configuration.html); de defaults zijn 0.0 en 0.5.
  vim.g.neovide_text_gamma = 0.8
  vim.g.neovide_text_contrast = 0.1
  -- Op 0, niet floating_blur = false: die bool verliest van transparantie.
  vim.g.neovide_floating_blur_amount_x = 0.0
  vim.g.neovide_floating_blur_amount_y = 0.0
  vim.g.neovide_floating_shadow = false
  vim.g.neovide_progress_bar_enabled = false

  -- Bevestiging bij onopgeslagen wijzigingen, ook bij sluiten via de menubalk.
  vim.g.neovide_confirm_quit = true

  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_theme = 'dark'
  vim.g.neovide_scale_factor = 1.0

  -- Dezelfde cursorvormen als set.lua, met een iets smallere balk en expliciete GUI-kleuren.
  vim.o.guicursor =
    'n-v-c-sm:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr-o:hor20-Cursor/lCursor,t:ver25-TermCursor'

  local function change_scale(delta)
    local scale = vim.g.neovide_scale_factor + delta
    vim.g.neovide_scale_factor = math.max(0.5, math.min(2.0, scale))
  end

  vim.keymap.set({ 'n', 'i', 'v', 'c', 't' }, '<D-k>', function() change_scale(0.03) end, { silent = true })
  vim.keymap.set({ 'n', 'i', 'v', 'c', 't' }, '<D-j>', function() change_scale(-0.03) end, { silent = true })
  vim.keymap.set(
    { 'n', 'i', 'v', 'c', 't' },
    '<D-0>',
    function() vim.g.neovide_scale_factor = 1.0 end,
    { silent = true }
  )

  -- Clipboard expliciet bedienen; de gewone Vim-registers blijven onafhankelijk.
  vim.keymap.set('x', '<D-c>', '"+y', { silent = true, desc = 'Kopieer selectie naar clipboard' })
  vim.keymap.set(
    { 'n', 'i', 'v', 'c', 't' },
    '<D-v>',
    function() vim.api.nvim_paste(vim.fn.getreg('+'), true, -1) end,
    { silent = true, desc = 'Plak clipboard' }
  )
end

return M
