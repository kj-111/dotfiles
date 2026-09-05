return {
  setup = function()
    require('blink.cmp').setup({
      keymap = {
        -- Ooit het native idioom leren (CTRL-Y accepteert, :h complete_CTRL-Y;
        -- Tab alleen voor snippets/inspringen): preset = 'default'.
        preset = 'super-tab',
      },
      completion = {
        menu = { scrollbar = false },
      },
      -- De cmdline is van de wildmenu; blink pakt hier
      -- anders <Tab> af.
      cmdline = { enabled = false },
      signature = {
        enabled = true,
        trigger = { enabled = false },
      },
    })
  end,
}
