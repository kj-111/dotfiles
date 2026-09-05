-- :make per projectvorm. De root zoeken we omhoog vanaf de buffer, zoals de
-- LSP-configs met hun root_markers; puur op de cwd vertrouwen breekt zodra je
-- een bestand van elders opent.
local root = vim.fs.root(0, { 'pom.xml', 'mvnw', 'gradlew', 'build.gradle', 'build.gradle.kts', '.java-root' })
local function has(f) return root ~= nil and vim.uv.fs_stat(vim.fs.joinpath(root, f)) ~= nil end

-- Leeg als je al in de projectmap zit, zodat het commando kort blijft.
local dir = (root == nil or root == vim.fn.getcwd()) and '' or root .. '/'

if has('pom.xml') or has('mvnw') then
  -- Meegeleverde compiler: mvn --batch-mode $params
  vim.b.maven_makeprg_params = (dir == '' and '' or '-f ' .. dir .. 'pom.xml ') .. 'compile'
  vim.cmd.compiler('maven')
  -- De wrapper pint de Maven-versie vast, dus die gaat voor op je eigen mvn.
  if has('mvnw') then
    local mvnw = dir == '' and './mvnw' or dir .. 'mvnw'
    vim.opt_local.makeprg = (vim.bo.makeprg:gsub('^mvn', function() return mvnw end))
  end
else
  vim.cmd.compiler('javac')
  if has('gradlew') or has('build.gradle') or has('build.gradle.kts') then
    local gradle = has('gradlew') and './gradlew' or 'gradle'
    vim.opt_local.makeprg = gradle .. (dir == '' and '' or ' -p ' .. dir) .. ' build'
  elseif has('src') then
    vim.opt_local.makeprg = ('javac -d %sout %ssrc/**/*.java'):format(dir, dir) -- jinit-layout
  else
    vim.opt_local.makeprg = 'javac %' -- los bestand, anders blijft makeprg kaal javac
  end
end

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '')
  .. ' | setlocal makeprg< errorformat< | unlet! b:current_compiler b:maven_makeprg_params'
