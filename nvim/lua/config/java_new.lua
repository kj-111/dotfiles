local M = {}

local config = {
  jinit = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath('config'), 'java-scratch', 'jinit')),
}

local templates = {
  { name = 'Plain Java', args = {}, main = 'src/Main.java' },
  { name = 'Maven + JUnit', args = { '--maven' }, main = 'src/main/java/Main.java' },
}

local function target_path(input)
  return vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(input), ':p'))
end

local function create_project(template, target)
  local cmd = vim.list_extend({ config.jinit }, template.args)
  table.insert(cmd, target)

  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR)
        return
      end

      vim.api.nvim_set_current_dir(target)
      vim.cmd.edit(vim.fs.joinpath(target, template.main))
      vim.notify(vim.trim(result.stdout))
    end)
  end)
end

local function prompt_target(template, initial)
  if initial and initial ~= '' then
    create_project(template, target_path(initial))
    return
  end

  vim.ui.input({ prompt = 'Project path: ' }, function(input)
    if not input or input == '' then return end
    create_project(template, target_path(input))
  end)
end

function M.new(initial)
  vim.ui.select(templates, {
    prompt = 'Java template:',
    format_item = function(item) return item.name end,
  }, function(template)
    if not template then return end
    prompt_target(template, initial)
  end)
end

function M.setup(opts)
  config = vim.tbl_extend('force', config, opts or {})

  vim.api.nvim_create_user_command('JavaNew', function(command)
    M.new(command.args)
  end, {
    nargs = '?',
    complete = 'dir',
  })
end

return M
