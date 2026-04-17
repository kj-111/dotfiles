return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  init_options = {
    settings = {
      configuration = {
        ['target-version'] = 'py313',
        lint = {
          select = {
            'E',
            'F',
            'I',
            'UP',
            'B',
            'C4',
            'RUF',
          },
          ignore = {
            'E501',
          },
        },
      },
    },
  },
}
