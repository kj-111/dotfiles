return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyrightconfig.json',
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    '.git',
  },
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = 'basic',
        useLibraryCodeForTypes = true,
        inlayHints = {
          callArgumentNames = true,
          callArgumentNamesMatching = false,
          functionReturnTypes = true,
          variableTypes = true,
        },
      },
    },
  },
}
