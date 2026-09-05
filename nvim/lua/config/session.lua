-- Sessie per projectmap: buffers, arglist, vensters en folds. Opgeslagen
-- buiten het project, dus geen Session.vim die je moet gitignoren. Wat er
-- precies in gaat bepaalt 'sessionoptions' (set.lua); docs/sessie.md.

local group = vim.api.nvim_create_augroup('user-session', { clear = true })
local session_dir = vim.fs.joinpath(vim.fn.stdpath('state'), 'sessions')

-- Alleen een herstelde of via :SessionCreate gemaakte sessie krijgt een pad.
-- Een :cd onderweg verlegt zo wel de cwd, maar niet het opslaganker.
local session_path = nil

local function path_for_cwd()
  -- getcwd(-1, -1) is de globale cwd, niet die van het venster na een :lcd.
  return vim.fs.joinpath(session_dir, vim.fn.getcwd(-1, -1):gsub('/', '%%') .. '.vim')
end

-- Herstellen mag alleen in een verse nvim. `nvim bestand` wil dat bestand, en
-- bij `... | nvim -` staat je gepipete tekst al in de buffer: in beide gevallen
-- zou de sessie eroverheen gaan.
local function fresh_start()
  if vim.fn.argc() > 0 then return false end

  return vim.api.nvim_buf_get_name(0) == ''
    and vim.api.nvim_buf_line_count(0) == 1
    and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == ''
end

vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Restore the session when nvim starts clean in this directory',
  group = group,
  nested = true,
  callback = function()
    if not fresh_start() then return end

    local path = path_for_cwd()
    if not vim.uv.fs_stat(path) then return end

    local ok, err = pcall(vim.cmd, 'source ' .. vim.fn.fnameescape(path))
    if not ok then
      vim.v.this_session = ''
      vim.notify('Projectsessie kon niet worden hersteld:\n' .. err, vim.log.levels.ERROR)
      return
    end

    -- Pas na een volledig geslaagde restore automatisch terugschrijven. Zo kan
    -- een fout sessiebestand bij het afsluiten niet door een halve restore
    -- worden overschreven.
    session_path = path
  end,
})

vim.api.nvim_create_user_command('SessionCreate', function()
  if session_path then
    vim.notify('Er is al een projectsessie actief.', vim.log.levels.INFO)
    return
  end

  local path = path_for_cwd()
  if vim.uv.fs_stat(path) then
    vim.notify(
      'Voor deze map bestaat al een sessie; start nvim zonder argumenten om die te herstellen.',
      vim.log.levels.WARN
    )
    return
  end

  vim.fn.mkdir(session_dir, 'p')
  vim.cmd('mksession ' .. vim.fn.fnameescape(path))

  session_path = path
  vim.notify('Projectsessie aangemaakt.', vim.log.levels.INFO)
end, { desc = 'Maak en activeer een sessie voor de huidige projectmap' })

vim.api.nvim_create_user_command('SessionDelete', function()
  local path = session_path or path_for_cwd()
  local active = session_path == path
  local exists = vim.uv.fs_stat(path) ~= nil

  if not exists and not active then
    vim.notify('Voor deze map bestaat geen projectsessie.', vim.log.levels.INFO)
    return
  end

  if exists then
    local ok, err = pcall(vim.fs.rm, path)
    if not ok then
      vim.notify('Projectsessie kon niet worden verwijderd:\n' .. err, vim.log.levels.ERROR)
      return
    end
  end

  if active then session_path = nil end

  -- `v:this_session` kan hetzelfde bestand via een opgelost symlinkpad noemen
  -- (op macOS bijvoorbeeld /private/tmp in plaats van /tmp).
  if active or vim.v.this_session == path then vim.v.this_session = '' end

  vim.notify(exists and 'Projectsessie verwijderd.' or 'Projectsessie gedeactiveerd.', vim.log.levels.INFO)
end, { desc = 'Verwijder en deactiveer de projectsessie' })

vim.api.nvim_create_autocmd('VimLeavePre', {
  desc = 'Save the session for this directory',
  group = group,
  callback = function()
    if not session_path then return end

    vim.fn.mkdir(session_dir, 'p')
    vim.cmd('mksession! ' .. vim.fn.fnameescape(session_path))
  end,
})
