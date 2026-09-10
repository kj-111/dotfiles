-- Verkenner als gewone buffer: een map is tekst, bewerken is bestandsbeheer.

return {
  setup = function()
    require('oil').setup({
      default_file_explorer = true,
      delete_to_trash = true,
      view_options = { show_hidden = true },
      win_options = { signcolumn = 'yes' },
      skip_confirm_for_simple_edits = true,
      lsp_file_methods = { enabled = true, autosave_changes = 'unmodified' },
      keymaps = {
        ['l'] = 'actions.select',
        ['h'] = { 'actions.parent', mode = 'n' },
      },
    })

    vim.keymap.set('n', '<leader>e', function()
      local oil = require('oil')
      if vim.bo.filetype == 'oil' then
        oil.close()
      else
        oil.open()
      end
    end, { desc = 'File Explorer' })
  end,
}
