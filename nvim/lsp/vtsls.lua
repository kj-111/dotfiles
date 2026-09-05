local function root_dir(bufnr, on_dir)
  local root_markers = {
    'jsconfig.json',
    'package.json',
    'package-lock.json',
    'yarn.lock',
    'pnpm-lock.yaml',
    'bun.lockb',
    'bun.lock',
  }
  local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
  local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
  local project_root = vim.fs.root(bufnr, root_markers)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local fallback_root = file ~= '' and vim.fs.dirname(file) or vim.fn.getcwd()

  -- Do not use .git as fallback: loose exercise files often redeclare globals like `assert`.
  -- Deno projects should not be handled by vtsls.
  if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then return end
  if deno_root and (not project_root or #deno_root >= #project_root) then return end

  on_dir(project_root or fallback_root)
end

return {
  cmd = { 'vtsls', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact' },
  root_dir = root_dir,
  settings = {
    javascript = {
      suggest = { completeFunctionCalls = true },
      updateImportsOnFileMove = { enabled = 'always' },
      inlayHints = {
        parameterNames = { enabled = 'literals', suppressWhenArgumentMatchesName = true },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
}
