return {
  setup = function()
    require('mini.pairs').setup()
    require('mini.icons').setup()

    -- Picker via :Pick <Tab>; mini.extra vult de registry met lsp, git,
    -- diagnostics, oldfiles, marks, keymaps.
    -- In de picker: Tab opent de preview. Naar de quickfix: CTRL-X markeert,
    -- CTRL-A markeert alle treffers, ALT-Enter opent ze samen als lijst.
    require('mini.pick').setup({
      window = {
        config = function()
          local height = math.floor(0.8 * vim.o.lines)
          local width = math.floor(0.8 * vim.o.columns)
          return {
            border = vim.o.winborder,
            anchor = 'NW',
            height = height,
            width = width,
            row = math.floor(0.5 * (vim.o.lines - height)),
            col = math.floor(0.5 * (vim.o.columns - width)),
          }
        end,
      },
    })
    require('mini.extra').setup()

    -- Arglist als picker; mini.extra heeft er geen, maar vim.fn.argv() geeft
    -- kale paden, dus preview en CTRL-V/S/T werken vanzelf (:h MiniPick-source).
    MiniPick.registry.arglist = function() return MiniPick.start({ source = { items = vim.fn.argv, name = 'Arglist' } }) end

    -- Verkenner in kolommen; bewerken is bestandsbeheer, = voert het uit.
    -- permanent_delete uit: verwijderd gaat naar mini's eigen prullenbak.
    require('mini.files').setup({ options = { permanent_delete = false } })

    vim.keymap.set('n', '<leader>e', function()
      local files = require('mini.files')
      if not files.close() then files.open(vim.api.nvim_buf_get_name(0)) end
    end)

    vim.keymap.set('n', '<leader>f', '<cmd>Pick files<CR>')
    vim.keymap.set('n', '<leader>g', '<cmd>Pick grep_live<CR>')
    vim.keymap.set('n', '<leader>b', '<cmd>Pick buffers<CR>')

    local clue = require('mini.clue')
    clue.setup({
      triggers = {
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },
        { mode = 'i', keys = '<C-x>' },
        { mode = 'n', keys = '<C-w>' },
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },
      },
      clues = {
        clue.gen_clues.square_brackets(),
        clue.gen_clues.builtin_completion(),
        clue.gen_clues.g(),
        clue.gen_clues.marks(),
        clue.gen_clues.registers(),
        clue.gen_clues.windows(),
        clue.gen_clues.z(),
      },
      window = {
        -- scrollen in het clue-venster: <C-d>/<C-u> (default scroll_down/scroll_up)
        delay = 300,
        config = { anchor = 'SW', row = 'auto', col = 0, width = 'auto' },
      },
    })
  end,
}
