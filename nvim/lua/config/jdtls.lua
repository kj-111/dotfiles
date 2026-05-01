local M = {}

local function resolve_settings_file(root_dir)
  local project_settings_file = vim.fs.joinpath(root_dir, '.settings', 'org.eclipse.jdt.core.prefs')

  if vim.uv.fs_stat(project_settings_file) then return project_settings_file end
end

local function start_jdtls(bufnr)
  local ok, jdtls = pcall(require, 'jdtls')
  if not ok then return end

  local root_dir = vim.fs.root(bufnr, {
    '.java-root',
    'mvnw',
    'gradlew',
    'pom.xml',
    'settings.gradle',
    'settings.gradle.kts',
    'build.gradle',
    'build.gradle.kts',
  })

  if not root_dir then return end

  local jdtls_cmd = vim.fn.exepath('jdtls')
  if jdtls_cmd == '' then
    vim.notify('jdtls niet gevonden op PATH. Installeer de binary via :MasonInstall jdtls.', vim.log.levels.WARN)
    return
  end

  local project_name = vim.fs.basename(root_dir)
  local project_hash = vim.fn.sha256(root_dir):sub(1, 12)
  local workspace_dir = vim.fs.joinpath(vim.fn.stdpath('cache'), 'jdtls-workspace', project_name .. '-' .. project_hash)
  local settings_file = resolve_settings_file(root_dir)
  local extended_client_capabilities = vim.deepcopy(jdtls.extendedClientCapabilities)
  extended_client_capabilities.resolveAdditionalTextEditsSupport = true

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
      guessMethodArguments = true,
      postfix = { enabled = true },
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

  jdtls.start_or_attach({
    cmd = { jdtls_cmd, '-data', workspace_dir },
    root_dir = root_dir,
    capabilities = require('blink.cmp').get_lsp_capabilities(),
    settings = {
      java = java_settings,
    },
    init_options = {
      extendedClientCapabilities = extended_client_capabilities,
    },
  })
end

function M.setup()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('jdtls-config', { clear = true }),
    pattern = 'java',
    callback = function(args) start_jdtls(args.buf) end,
  })
end

return M
