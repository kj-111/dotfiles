-- Mét Makefile doet de standaard-makeprg ('make') het al; dit is de fallback
-- voor losse bestanden: make's impliciete regel kent %.c → % (cc roept zichzelf
-- aan), en %:r wordt door :make vervangen door het bestand zonder extensie.
-- cpp erft dit bestand via runtime! ftplugin/c.vim, maar de C++-regel is
-- $(LINK.cpp) en die leest CXXFLAGS, niet CFLAGS.
-- Omhoog zoeken vanaf de buffer, zoals java.lua: op de cwd afgaan mist de
-- Makefile zodra je het bestand van elders opent.
if vim.fs.root(0, { 'Makefile', 'makefile' }) == nil then
  local variable = vim.bo.filetype == 'cpp' and 'CXXFLAGS' or 'CFLAGS'
  local flags = vim.bo.filetype == 'cpp' and '-Wall -Wextra -g' or '-std=c23 -Wall -Wextra -g'
  vim.opt_local.makeprg = ("make %s='%s' %%:r"):format(variable, flags)
end

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '') .. ' | setlocal makeprg<'
