return {
  -- --clang-tidy: statische checks inline naast de compiler-diagnostics.
  -- Welke checks en welke fallback-compileflags: ~/.config/clangd/config.yaml
  -- --log=error voorkomt dat clangd's gewone request-trace het LSP-log vult.
  cmd = { 'clangd', '--background-index', '--clang-tidy', '--log=error' },
  filetypes = { 'c', 'cpp' },
  root_markers = {
    {
      '.clangd',
      '.clang-tidy',
      'compile_commands.json',
      'compile_flags.txt',
      'configure.ac',
      'Makefile',
      'makefile',
      '.git',
    },
  },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
  },
}
