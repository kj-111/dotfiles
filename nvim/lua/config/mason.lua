local M = {}

local tools = {
  'clangd',
  'jdtls',
  'lua-language-server',
  'prettierd',
  'pyright',
  'ruff',
  'stylua',
  'tree-sitter-cli',
  'typescript-language-server',
}

function M.setup()
  require('mason').setup({
    PATH = 'prepend',
  })

  vim.api.nvim_create_user_command(
    'MasonEnsureTools',
    function() vim.cmd('MasonInstall ' .. table.concat(tools, ' ')) end,
    {
      desc = 'Install configured Mason LSPs and formatters',
    }
  )
end

return M
