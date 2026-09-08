-- Bewerkbaar menu op de arglist. De buffer ís de lijst: één pad per regel,
-- dus dd, <C-j> en <C-k> zijn gewoon Vim. Bij het sluiten van het venster wordt
-- de arglist uit de regels herbouwd. Zie docs/navigatie.md.
--
-- De lijst overleeft het afsluiten zodra je in deze map :SessionCreate hebt
-- gedaan: de sessie schrijft hem mee weg, inclusief het huidige slot (sessie.md).

local group = vim.api.nvim_create_augroup('user-arglist', { clear = true })
local menu_win = nil

local function absolute(path, cwd)
  return vim.fs.normalize(path:sub(1, 1) == '/' and path or vim.fs.joinpath(cwd, path), { expand_env = false })
end

local function rebuild(buf, cwd)
  local files, seen = {}, {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if line ~= '' then
      local path = absolute(line, cwd)
      if not seen[path] then
        files[#files + 1], seen[path] = path, true
      end
    end
  end

  local old, index = vim.fn.argv(), vim.fn.argidx()
  local current = old[index + 1]
  local anchor = current and vim.fn.index(files, vim.fn.fnamemodify(current, ':p')) + 1 or 0
  local function add(paths, count)
    if #paths == 0 then return end
    vim.cmd.argadd({
      args = vim.tbl_map(vim.fn.fnameescape, paths),
      range = { count },
      magic = { file = false, bar = false },
    })
  end
  -- Behoud het huidige argument als anker, zonder :edit of foldverlies.
  if anchor > 0 then
    if index + 1 < #old then vim.cmd.argdelete({ range = { index + 2, #old } }) end
    if index > 0 then vim.cmd.argdelete({ range = { 1, index } }) end
    add(vim.list_slice(files, 1, anchor - 1), 0)
    add(vim.list_slice(files, anchor + 1), vim.fn.argc())
  else
    if #old > 0 then vim.cmd.argdelete({ range = { 1, #old } }) end
    add(files, 0)
  end
end

-- Zit je al in dit bestand, roep :argument dan niet aan: het is een :edit, die
-- herleest, en bij het herlezen gaan je handmatig gesloten folds verloren.
local function goto_slot(n)
  local target = vim.fn.argv(n - 1)
  if target == '' then return end
  if vim.fn.fnamemodify(target, ':p') == vim.fn.expand('%:p') then return end
  local ok, err = pcall(vim.cmd.argument, { range = { n } })
  if not ok then vim.notify(err, vim.log.levels.WARN) end
end

local function open()
  -- Vastleggen vóór het venster opent, want daarna is de scratch-buffer de
  -- huidige en is er geen bestandsnaam meer om toe te voegen.
  local origin = vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) or ''
  local origin_win, cwd = vim.api.nvim_get_current_win(), vim.fn.getcwd()
  local files = vim.fn.argv()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, files)

  local width = math.max(1, math.min(80, vim.o.columns - 8))
  local height = math.max(1, math.min(#files, vim.o.lines - 6))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    title = ' arglist ',
  })

  menu_win = win

  -- style=minimal zet 'number' uit; hier juist aan, want het regelnummer ís het
  -- slot waar CTRL-1 t/m CTRL-6 naartoe springt.
  vim.wo[win].number = true
  vim.wo[win].wrap = false
  vim.bo[buf].bufhidden = 'wipe'

  local function add()
    if origin == '' then
      vim.notify('Het bestand waar je vandaan kwam heeft geen naam.', vim.log.levels.INFO)
      return
    end

    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      if line ~= '' and absolute(line, cwd) == origin then return end
    end

    local last = vim.api.nvim_buf_line_count(buf)
    -- Een verse buffer heeft één lege regel; die overschrijven in plaats van
    -- eronder plakken, anders begint de lijst met een gat.
    local start = (last == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == '') and 0 or last
    vim.api.nvim_buf_set_lines(buf, start, -1, false, { origin })
    vim.api.nvim_win_set_height(win, math.max(1, math.min(vim.api.nvim_buf_line_count(buf), vim.o.lines - 6)))
  end

  local function close()
    vim.api.nvim_win_close(win, false)
    if not vim.api.nvim_win_is_valid(origin_win) then return false end
    vim.api.nvim_set_current_win(origin_win)
    return true
  end

  local function jump()
    local slot = vim.api.nvim_win_get_cursor(win)[1]
    local line = vim.api.nvim_buf_get_lines(buf, slot - 1, slot, false)[1]
    if not line or line == '' then return end
    local target = absolute(line, cwd)
    -- Zoek na deduplicatie op pad: lege/dubbele regels veranderen het slot.
    if not close() then return end
    for i, path in ipairs(vim.fn.argv()) do
      if vim.fn.fnamemodify(path, ':p') == target then
        goto_slot(i)
        return
      end
    end
  end

  vim.keymap.set('n', 'a', add, { buf = buf, desc = 'Bestand van herkomst toevoegen' })
  vim.keymap.set('n', 'l', jump, { buf = buf, desc = 'Open dit slot' })
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buf = buf, desc = 'Sluiten' })
  for i = 1, 6 do
    vim.keymap.set('n', '<C-' .. i .. '>', function()
      if close() then goto_slot(i) end
    end, { buf = buf, desc = 'Arglist-slot ' .. i })
  end

  -- Focus weg = menu weg. Gepland, want een venster sluiten midden in de
  -- vensterwissel mag niet; de guard vangt de routes die zelf al sloten.
  vim.api.nvim_create_autocmd('WinLeave', {
    group = group,
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if menu_win == win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, false) end
      end)
    end,
  })

  -- Elke manier van sluiten schrijft terug, ook :q of wegklikken.
  vim.api.nvim_create_autocmd('BufWinLeave', {
    group = group,
    buffer = buf,
    once = true,
    callback = function()
      menu_win = nil
      if vim.deep_equal(files, vim.api.nvim_buf_get_lines(buf, 0, -1, false)) then return end
      if vim.api.nvim_win_is_valid(origin_win) then
        vim.api.nvim_win_call(origin_win, function() rebuild(buf, cwd) end)
      end
    end,
  })
end

local function toggle()
  if menu_win and vim.api.nvim_win_is_valid(menu_win) then
    vim.api.nvim_win_close(menu_win, false)
    return
  end
  open()
end

vim.keymap.set('n', '<leader>h', toggle, { desc = 'Arglist-menu' })

-- Geregistreerd vóór config.session: sla menu-edits mee op bij :qa.
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = group,
  nested = true,
  callback = function()
    if menu_win and vim.api.nvim_win_is_valid(menu_win) then vim.api.nvim_win_close(menu_win, false) end
  end,
})

-- Ctrl+cijfer vergt het uitgebreide toetsenbordprotocol (Alacritty).
for i = 1, 6 do
  vim.keymap.set('n', '<C-' .. i .. '>', function() goto_slot(i) end, { desc = 'Arglist-slot ' .. i })
end
