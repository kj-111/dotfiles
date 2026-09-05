local M = {}

local function resolve_settings_file(root_dir)
  local project_settings_file = vim.fs.joinpath(root_dir, '.settings', 'org.eclipse.jdt.core.prefs')

  if vim.uv.fs_stat(project_settings_file) then return project_settings_file end
end

function M.start(bufnr, capabilities)
  local ok, jdtls = pcall(require, 'jdtls')
  if not ok then return end

  -- Nested groups set priority: wrapper/settings files mark the true project root,
  -- so a submodule pom.xml/build.gradle in a multi-module project does not win.
  local root_dir = vim.fs.root(bufnr, {
    { '.java-root', 'mvnw', 'gradlew', 'settings.gradle', 'settings.gradle.kts' },
    { 'pom.xml', 'build.gradle', 'build.gradle.kts' },
  })

  if not root_dir then
    vim.notify(
      'Geen projectroot gevonden. Maak een marker aan met `touch .java-root` in de projectmap.',
      vim.log.levels.WARN
    )
    return
  end

  local jdtls_cmd = vim.fn.exepath('jdtls')
  if jdtls_cmd == '' then
    vim.notify('jdtls niet gevonden op PATH. Installeer de binary via brew install jdtls.', vim.log.levels.WARN)
    return
  end

  local project_name = vim.fs.basename(root_dir)
  local project_hash = vim.fn.sha256(root_dir):sub(1, 12)
  local workspace_dir = vim.fs.joinpath(vim.fn.stdpath('cache'), 'jdtls-workspace', project_name .. '-' .. project_hash)
  local settings_file = resolve_settings_file(root_dir)

  local java_settings = {
    signatureHelp = { enabled = true },
    configuration = {
      updateBuildConfiguration = 'interactive',
    },
    eclipse = {
      downloadSources = true,
    },
    maven = {
      downloadSources = true,
    },
    completion = {
      -- Modern enum spelling of the legacy boolean `true`.
      guessMethodArguments = 'insertBestGuessedArguments',
      postfix = { enabled = true },
      -- Superset of the jdtls defaults (the setting replaces them), plus Mockito and AssertJ.
      favoriteStaticMembers = {
        'org.junit.Assert.*',
        'org.junit.Assume.*',
        'org.junit.jupiter.api.Assertions.*',
        'org.junit.jupiter.api.Assumptions.*',
        'org.junit.jupiter.api.DynamicContainer.*',
        'org.junit.jupiter.api.DynamicTest.*',
        'org.mockito.Mockito.*',
        'org.mockito.ArgumentMatchers.*',
        'org.mockito.Answers.*',
        'org.assertj.core.api.Assertions.*',
      },
    },
    codeGeneration = {
      hashCodeEquals = { useInstanceof = true },
      toString = { codeStyle = 'STRING_BUILDER' },
      useBlocks = true,
    },
  }

  if settings_file then java_settings.settings = {
    url = vim.uri_from_fname(settings_file),
  } end

  local cmd = { jdtls_cmd, '-data', workspace_dir }

  jdtls.start_or_attach({
    cmd = cmd,
    root_dir = root_dir,
    -- nvim-jdtls gaat via vim.lsp.start(), dat niet naar vim.lsp.config('*')
    -- kijkt; capabilities dus expliciet meegeven.
    capabilities = capabilities,
    settings = {
      java = java_settings,
    },
  }, nil, { bufnr = bufnr })
end

function M.setup(capabilities)
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('jdtls-config', { clear = true }),
    pattern = 'java',
    callback = function(args) M.start(args.buf, capabilities) end,
  })
end

return M
