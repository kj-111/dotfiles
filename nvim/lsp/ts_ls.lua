local tsserver_name = vim.fn.has('win32') == 1 and 'typescript-language-server.cmd' or 'typescript-language-server'

local function root_dir(bufnr, on_dir)
  local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
  local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
  local project_root = vim.fs.root(bufnr, {
    { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' },
    { '.git' },
  })

  if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then return end
  if deno_root and (not project_root or #deno_root >= #project_root) then return end

  on_dir(project_root or vim.fn.getcwd())
end

return {
  cmd = { tsserver_name, '--stdio' },
  filetypes = { 'javascript' },
  root_dir = root_dir,
  init_options = {
    hostInfo = 'neovim',
  },
  settings = {
    completions = { completeFunctionCalls = true },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'literals',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayEnumMemberValueHints = false,
      },
      updateImportsOnFileMove = { enabled = 'always' },
    },
  },
}
