vim.keymap.set('n', '<C-i>', '<C-^>')
vim.keymap.set('n', '<C-e>', function() vim.cmd(vim.bo.filetype == 'netrw' and 'bd' or 'Explore') end)
vim.keymap.set('n', '<leader>u', '<cmd>Undotree<CR>')

vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('t', '<C-[>', '<C-\\><C-n>')
