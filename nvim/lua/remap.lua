local function switch_last_file_buffer()
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.tbl_filter(function(buffer)
    if buffer.bufnr == current or buffer.loaded ~= 1 or buffer.name == '' then return false end
    if vim.bo[buffer.bufnr].buftype ~= '' then return false end
    if vim.bo[buffer.bufnr].filetype == 'netrw' then return false end
    return true
  end, vim.fn.getbufinfo({ buflisted = 1 }))

  table.sort(buffers, function(left, right) return (left.lastused or 0) > (right.lastused or 0) end)

  if not buffers[1] then
    vim.notify('No previous file buffer', vim.log.levels.INFO)
    return
  end

  vim.api.nvim_set_current_buf(buffers[1].bufnr)
end

vim.keymap.set('n', '<C-i>', switch_last_file_buffer)
vim.keymap.set('n', '<C-e>', function() vim.cmd(vim.bo.filetype == 'netrw' and 'bd' or 'Explore') end)
vim.keymap.set('n', '<leader>u', '<cmd>Undotree<CR>')
vim.keymap.set('n', '<leader>v', '<cmd>Markview toggle<CR>')

vim.keymap.set('n', '<C-j>', '<cmd>m .+1<CR>==', { silent = true })
vim.keymap.set('n', '<C-k>', '<cmd>m .-2<CR>==', { silent = true })
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('t', '<C-[>', '<C-\\><C-n>')
vim.keymap.set('t', 'jk', '<C-\\><C-n>')
