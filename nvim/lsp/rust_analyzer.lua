local function root_dir(bufnr, on_dir)
  local path = vim.api.nvim_buf_get_name(bufnr)
  -- Dependencybroncode hoort bij de actieve workspace, niet bij een nieuwe LSP.
  local cargo_home = vim.env.CARGO_HOME or vim.fs.joinpath(vim.env.HOME, '.cargo')
  local rustup_home = vim.env.RUSTUP_HOME or vim.fs.joinpath(vim.env.HOME, '.rustup')
  for _, library in ipairs({
    cargo_home .. '/registry/src',
    cargo_home .. '/git/checkouts',
    rustup_home .. '/toolchains',
  }) do
    if vim.fs.relpath(library, path) then
      local clients = vim.lsp.get_clients({ name = 'rust_analyzer' })
      if #clients > 0 then on_dir(clients[#clients].root_dir) end
      return
    end
  end
  local cargo_root = vim.fs.root(path, 'Cargo.toml')

  if not cargo_root then
    on_dir(vim.fs.root(path, 'rust-project.json'))
    return
  end

  if vim.fn.executable('cargo') == 0 then
    vim.notify_once('Rust: cargo ontbreekt in PATH; installeer de rustup-toolchain.', vim.log.levels.WARN)
    return
  end

  vim.system(
    { 'cargo', 'metadata', '--no-deps', '--format-version', '1', '--manifest-path', cargo_root .. '/Cargo.toml' },
    { text = true, cwd = cargo_root },
    function(result)
      local ok, metadata = pcall(vim.json.decode, result.stdout or '')
      local workspace_root = ok and type(metadata) == 'table' and metadata.workspace_root or cargo_root
      on_dir(vim.fs.normalize(workspace_root))
    end
  )
end

return {
  -- In Neovim 0.12 erft een array-cmd de editor-cwd, niet de projectroot.
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start({ 'rust-analyzer' }, dispatchers, { cwd = config.root_dir })
  end,
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
