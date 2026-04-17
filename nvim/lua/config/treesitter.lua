-- stylua: ignore
local parsers = {
  'bash', 'c', 'java', 'javascript', 'json', 'lua',
  'markdown', 'markdown_inline', 'python', 'vim', 'vimdoc', 'xml',
}

local function set_window_folds(_, win)
  vim.wo[win][0].foldmethod = 'expr'
  vim.wo[win][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
end

return {
  setup = function()
    require('nvim-treesitter').install(parsers)

    local group = vim.api.nvim_create_augroup('treesitter-config', { clear = true })

    vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
      group = group,
      callback = function(args)
        if args.event == 'FileType' and pcall(vim.treesitter.start, args.buf) then
          vim.b[args.buf].treesitter_enabled = true
        end
        if vim.b[args.buf].treesitter_enabled then set_window_folds(args.buf, vim.api.nvim_get_current_win()) end
      end,
    })
  end,
}
