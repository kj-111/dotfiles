vim.keymap.set('n', '<leader>i', '<C-^>')

vim.keymap.set('n', '<C-j>', '<cmd>m .+1<CR>==', { silent = true })
vim.keymap.set('n', '<C-k>', '<cmd>m .-2<CR>==', { silent = true })

vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- CTRL-[ ís Esc, ingebouwd (:h i_CTRL-[))
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('t', 'jk', '<C-\\><C-n>')

-- Alle diagnostics in de quickfixlijst; setqflist opent ze zelf.
vim.keymap.set('n', '<leader>d', function() vim.diagnostic.setqflist() end, { desc = 'Diagnostics in quickfix' })

-- De arglist als harpoon; $argadd = achteraan, :%argdel wist de hele lijst.
vim.keymap.set('n', '<leader>a', '<cmd>$argadd % | argdedupe<CR>')

-- Ctrl+cijfer vergt het uitgebreide toetsenbordprotocol (Alacritty).
for i = 1, 6 do
  vim.keymap.set('n', '<C-' .. i .. '>', function()
    -- Zit je al in dit bestand, roep :argument dan niet aan: het is een :edit,
    -- die herleest, en bij het herlezen gaan je handmatige folds verloren
    local target = vim.fn.argv(i - 1)
    if target ~= '' and vim.fn.fnamemodify(target, ':p') == vim.fn.expand('%:p') then return end
    vim.cmd('silent! ' .. i .. 'argument')
  end)
end

-- :!sioyek werkt niet: een niet-interactieve zsh kent de zshrc-alias niet en
-- start de kale binary in de voorgrond, mét al zijn Qt-meldingen.
vim.api.nvim_create_user_command('Sioyek', function(opts)
  local file = opts.args ~= '' and vim.fn.fnamemodify(opts.args, ':p') or vim.fn.expand('%:p')

  vim.system({ 'open', '-a', 'Sioyek', file }, { text = true }, function(res)
    if res.code ~= 0 then vim.schedule(function() vim.notify(vim.trim(res.stderr), vim.log.levels.ERROR) end) end
  end)
end, { nargs = '?', complete = 'file', desc = 'Open een PDF in Sioyek' })
