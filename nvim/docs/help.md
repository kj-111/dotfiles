# Help: nvim is self-explanatory

Werkregel (neovim-core): eerst K of :h, dan de bron, AI laatst.

## Neovim zelf

- `:Tutor` — de interactieve tutorial: 30 minuten, leert de basis hands-on (:h vimtutor)
- `:h user-manual` — de gids: taakgericht, van simpel naar complex, "reads from
  start to end like a book" (:h usr_01); per hoofdstuk springen: `:h usr_02`, `:h usr_03`, …
- `:h nvim-quickstart` — nvim's eigen "What now?": de kortste ingang, wijst
  naar de Tutor en verder
- `:h lua-guide` — Lua voor je config (opties, maps, autocmds): "Think of it
  as a survival kit" — de brug tussen de user-manual en de Lua-API
- `:h lsp-quickstart` — native LSP in drie stappen: server installeren,
  `vim.lsp.config`, `vim.lsp.enable` — precies zo doet config/lsp.lua het
- `:h onderwerp` — fuzzy zoeken met Tab; weet je de notatie: 'optie', :cmd, functie(), i_CTRL-X (:h help-summary)
- `:tab h onderwerp` — zelfde, maar fullscreen in een eigen tab in plaats
  van een split; werkt vóór elk venster-openend commando (:h :tab, met
  precies dit als voorbeeld). Tab dicht: `:q`, wisselen: `gt`
- `gO` — inhoudstafel van de open helppagina
- `CTRL-]` — volg de link onder de cursor; `CTRL-T` — terug (werkt gestapeld)
- `:helpgrep patroon` — doorzoek álle help, resultaat in quickfix (]q / [q)
- mini.clue — prefix indrukken (`<leader>`, g, z, [, ], CTRL-W, ") en 300 ms wachten: het menu toont wat er bestaat; onbekende toets gezien → :h die-toets
- `:h index` en `:h default-mappings` — alles wat ingebouwd is
- `:checkhealth` — is alles gezond: providers, lsp, treesitter, plugins
- `ZR` — nvim herstarten mét je sessie: hij bewaart de boel, start opnieuw
  en zet alles terug (`:restart`, :h ZR). De derde uit de Z-familie naast
  `ZZ` (opslaan en weg) en `ZQ` (weg zonder opslaan); handig na een
  config-wijziging die een herstart vraagt

## Plugins

Elke plugin scheept zijn eigen handleiding mee, doorzoekbaar als gewone help:
`:h mini.clue`, `:h mini.pick`, `:h mini.files`, `:h conform`,
`:h blink-cmp`, `:h fugitive` — en in de mini.files- en fugitive-buffers
toont `g?` alle toetsen van dát venster. Undotree is geen losse plugin maar
een meegeleverde van nvim zelf: `:h package-undotree`.

## Code (jdtls / LSP)

`K` vraagt "wat is dit?", `CTRL-]` vraagt "hoe werkt het echt?" — die
springt naar de échte broncode, ook van JDK-klassen, waar de volle javadoc
als comment staat. De vier routes met een voorbeeld, en de rest van de
toetsen: lsp-keys.md.

## Buiten nvim

- `:Man iets` — man-pages als doorzoekbare buffer (shell: K doet dit vanzelf)
- `:Sioyek [bestand.pdf]` — open de opgegeven PDF, of de huidige buffer, in Sioyek
- offline referenties (JDK 25, Python, MDN): ~/academia/books/references/ — in de browser
- Greenfoot-javadoc: K/CTRL-] dekken de API; het bredere verhaal: ~/academia/uni/java/notes/greenfoot.pdf

## De volgorde bij een vraag

K (wat is dit?) → CTRL-] (hoe werkt het echt?) → :h / :helpgrep (nvim-vraag) → referentie in de browser (model-vraag) → AI (pas als het bovenstaande het niet was).
