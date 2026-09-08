-- Harpoon-achtig menu op de arglist. De buffer ís de lijst: één pad per regel,
-- dus dd, <C-j> en <C-k> zijn gewoon Vim. Bij het sluiten van het venster wordt
-- de arglist uit de regels herbouwd. Zie docs/navigatie.md.
--
-- De lijst overleeft het afsluiten zodra je in deze map :SessionCreate hebt
-- gedaan: de sessie schrijft hem mee weg, inclusief het huidige slot (sessie.md).

local group = vim.api.nvim_create_augroup('user-arglist', { clear = true })
local menu_win = nil

local function rebuild(buf)
  local files = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    line = vim.trim(line)
    if line ~= '' then files[#files + 1] = vim.fn.fnameescape(line) end
  end

  if vim.fn.argc() > 0 then vim.cmd('%argdelete') end
  if #files > 0 then vim.cmd('$argadd ' .. table.concat(files, ' ') .. ' | argdedupe') end
end

-- Zit je al in dit bestand, roep :argument dan niet aan: het is een :edit, die
-- herleest, en bij het herlezen gaan je handmatig gesloten folds verloren.
local function goto_slot(n)
  local target = vim.fn.argv(n - 1)
  if target == '' then return end
  if vim.fn.fnamemodify(target, ':p') == vim.fn.expand('%:p') then return end
  vim.cmd('silent! ' .. n .. 'argument')
end

local function open()
  -- Vastleggen vóór het venster opent, want daarna is de scratch-buffer de
  -- huidige en is er geen bestandsnaam meer om toe te voegen.
  local origin = vim.fn.expand('%')
  local files = vim.fn.argv()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, files)

  local width = math.min(80, vim.o.columns - 8)
  local height = math.max(#files, 1)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    title = ' arglist ',
  })

  menu_win = win

  -- style=minimal zet 'number' uit; hier juist aan, want het regelnummer ís het
  -- slot waar CTRL-1 t/m CTRL-6 naartoe springt.
  vim.wo[win].number = true
  vim.bo[buf].bufhidden = 'wipe'

  local function add()
    if origin == '' then
      vim.notify('Het bestand waar je vandaan kwam heeft geen naam.', vim.log.levels.INFO)
      return
    end

    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      if vim.trim(line) == origin then return end
    end

    local last = vim.api.nvim_buf_line_count(buf)
    -- Een verse buffer heeft één lege regel; die overschrijven in plaats van
    -- eronder plakken, anders begint de lijst met een gat.
    local start = (last == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == '') and 0 or last
    vim.api.nvim_buf_set_lines(buf, start, -1, false, { origin })
    vim.api.nvim_win_set_height(win, vim.api.nvim_buf_line_count(buf))
  end

  local function jump()
    local slot = vim.api.nvim_win_get_cursor(win)[1]
    -- Sluiten herbouwt de arglist uit de buffer, dus daarna klopt het slot.
    vim.api.nvim_win_close(win, false)
    goto_slot(slot)
  end

  vim.keymap.set('n', 'a', add, { buf = buf, desc = 'Bestand van herkomst toevoegen' })
  vim.keymap.set('n', 'l', jump, { buf = buf, desc = 'Open dit slot' })
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buf = buf, desc = 'Sluiten' })

  -- Focus weg = menu weg. Gepland, want een venster sluiten midden in de
  -- vensterwissel mag niet; de guard vangt de routes die zelf al sloten.
  vim.api.nvim_create_autocmd('WinLeave', {
    group = group,
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if menu_win and vim.api.nvim_win_is_valid(menu_win) then vim.api.nvim_win_close(menu_win, false) end
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
      rebuild(buf)
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

-- Ctrl+cijfer vergt het uitgebreide toetsenbordprotocol (Alacritty).
for i = 1, 6 do
  vim.keymap.set('n', '<C-' .. i .. '>', function() goto_slot(i) end, { desc = 'Arglist-slot ' .. i })
end
