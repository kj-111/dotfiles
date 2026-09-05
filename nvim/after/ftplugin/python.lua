-- De meegeleverde ftplugin zet pytest alleen voor bestanden die zelf test_*.py
-- of *_test.py heten, mét dat bestand als argument. Vanuit gewone code wil je
-- de hele suite kunnen draaien: zelfde profiel, zonder argument.
-- Wel eerst kijken of het project tests heeft, net als java.lua op projectvorm
-- kiest; anders zou :make in elk los scriptje een willekeurige cwd afzoeken.
-- Linten hoort hier niet: ruff draait als LSP-server en meldt live.
local markers = { 'pytest.ini', 'pyproject.toml', 'setup.cfg', 'tox.ini', 'tests' }
local root = vim.fs.root(0, markers)

if vim.b.current_compiler == nil and vim.fn.executable('pytest') == 1 and root ~= nil then
  vim.cmd.compiler('pytest')
end

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '')
  .. ' | setlocal makeprg< errorformat< | unlet! b:current_compiler b:pytest_makeprg_params'
