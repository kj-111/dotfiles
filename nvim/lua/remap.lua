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
