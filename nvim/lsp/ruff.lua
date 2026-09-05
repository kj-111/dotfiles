return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  init_options = {
    settings = {
      logLevel = 'error',
    },
  },

  -- Match basedpyright's encoding; mixed encodings on one buffer force
  -- Neovim into a slower compatibility mode.
  capabilities = {
    general = {
      positionEncodings = { 'utf-16' },
    },
  },

  on_init = function(client)
    -- Keep Ruff focused on linting; BasedPyright provides Python hover.
    client.server_capabilities.hoverProvider = false
  end,

  -- Note: Specific linting rules (select, ignore) and target-version
  -- are configured globally in ~/.config/ruff/ruff.toml so that CLI
  -- tools and Neovim share the exact same configuration.
}
