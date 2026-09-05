-- Wrapped visual navigation: j/k bewegen per schermregel, maar met een teller
-- (5j) tellen ze echte regels, zodat relativenumber blijft kloppen.
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

vim.keymap.set('n', 'j', function() return vim.v.count == 0 and 'gj' or 'j' end, { buf = 0, expr = true })
vim.keymap.set('n', 'k', function() return vim.v.count == 0 and 'gk' or 'k' end, { buf = 0, expr = true })

-- Autopairs in proza sluit meer dan je wil: elke ( en " krijgt een partner.
vim.b.minipairs_disable = true

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '')
  .. ' | setlocal wrap< linebreak< breakindent<'
  .. " | silent! execute 'nunmap <buffer> j' | silent! execute 'nunmap <buffer> k'"
  .. ' | unlet! b:minipairs_disable'
