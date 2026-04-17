return {
  setup = function()
    require('blink.cmp').setup({
      keymap = { preset = 'super-tab', ['<C-l>'] = { 'show', 'show_documentation', 'hide_documentation' } },
      completion = {
        menu = { scrollbar = false },
      },
      signature = {
        enabled = true,
        trigger = { enabled = false },
      },
    })
  end,
}
