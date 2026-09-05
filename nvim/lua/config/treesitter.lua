-- stylua: ignore
local parsers = {
  'bash', 'c', 'cpp', 'html', 'java', 'javascript', 'json', 'lua',
  'latex', 'markdown', 'markdown_inline', 'python', 'toml', 'vim', 'vimdoc', 'xml', 'yaml',
}

return {
  setup = function()
    require('nvim-treesitter').install(parsers)

    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-config', { clear = true }),
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
