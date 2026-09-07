local function root_dir(bufnr, on_dir)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local cargo_root = vim.fs.root(path, 'Cargo.toml')

  if not cargo_root then
    on_dir(vim.fs.root(path, 'rust-project.json'))
    return
  end

  vim.system(
    { 'cargo', 'metadata', '--no-deps', '--format-version', '1', '--manifest-path', cargo_root .. '/Cargo.toml' },
    { text = true },
    function(result)
      local ok, metadata = pcall(vim.json.decode, result.stdout or '')
      local workspace_root = ok and type(metadata) == 'table' and metadata.workspace_root or cargo_root
      on_dir(vim.fs.normalize(workspace_root))
    end
  )
end

return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_dir = root_dir,
  workspace_required = true,
  settings = {
    ['rust-analyzer'] = {
      check = { command = 'clippy' },
    },
  },
  before_init = function(init_params, config) init_params.initializationOptions = config.settings['rust-analyzer'] end,
}
