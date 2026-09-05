-- Eén zwevende terminal, met <C-f> ervoor en er weer vanaf.
--
-- Het blijft dezelfde shell zolang je hem niet afsluit. <C-f> doet
-- nvim_win_hide: dat sluit enkel het venster, de buffer en het proces blijven
-- leven. Je halve commando, je scrollback, je cd — alles staat er nog, en een
-- draaiende make loopt door terwijl jij verder typt.
--
-- Pas exit (of CTRL-D) in de shell zelf ruimt op: on_exit gooit venster én
-- buffer weg en de volgende <C-f> start een verse. Nvim afsluiten doet dat
-- ook; er wordt niets bewaard tussen sessies.

local state = { buf = -1, win = -1 }

-- 0.9 van het scherm. De rand telt daarin mee en nvim clampt niet, dus die
-- twee cellen er expliciet af; anders valt de onderrand op de cmdline. Geen
-- border in de config: floats volgen vanzelf 'winborder' (set.lua).
local function geometry()
  local rows = vim.o.lines - vim.o.cmdheight
  local height = math.floor(0.9 * rows) - 2
  local width = math.floor(0.9 * vim.o.columns) - 2
  return {
    relative = 'editor',
    height = height,
    width = width,
    row = math.floor(0.5 * (rows - height - 2)),
    col = math.floor(0.5 * (vim.o.columns - width - 2)),
  }
end

local function toggle()
  local open = vim.api.nvim_win_is_valid(state.win)
  -- Een float hoort bij één tabpagina. Staat hij in een andere, dan wil je hem
  -- híer, niet erheen gesleept worden.
  local here = open and vim.api.nvim_win_get_tabpage(state.win) == vim.api.nvim_get_current_tabpage()

  if here then
    -- Met CTRL-W w kun je de float uit stappen zonder hem weg te schuiven;
    -- dan wil <C-f> hem terug in focus, niet dicht.
    if vim.api.nvim_get_current_win() == state.win then
      vim.api.nvim_win_hide(state.win)
    else
      vim.api.nvim_set_current_win(state.win)
    end
    return
  end

  -- Daarginds weghalen; de buffer blijft, dus hieronder komt dezelfde shell terug.
  if open then vim.api.nvim_win_hide(state.win) end

  if not vim.api.nvim_buf_is_valid(state.buf) then state.buf = vim.api.nvim_create_buf(false, true) end
  state.win = vim.api.nvim_open_win(state.buf, true, geometry())

  -- Pas starten als het venster er staat, anders krijgt de pty eerst de
  -- standaardmaat en herschikt de shell zijn prompt bij de eerste tekens.
  if vim.bo[state.buf].buftype ~= 'terminal' then
    vim.fn.jobstart(vim.o.shell, {
      term = true,
      on_exit = function()
        if vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_win_close(state.win, true) end
        if vim.api.nvim_buf_is_valid(state.buf) then vim.api.nvim_buf_delete(state.buf, { force = true }) end
      end,
    })
  end
end

return {
  setup = function()
    vim.keymap.set({ 'n', 't' }, '<C-f>', toggle)

    vim.api.nvim_create_autocmd('VimResized', {
      desc = 'Keep the floating terminal centred',
      group = vim.api.nvim_create_augroup('user-term', { clear = true }),
      callback = function()
        if vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_win_set_config(state.win, geometry()) end
      end,
    })
  end,
}
