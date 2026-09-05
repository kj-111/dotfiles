# Pick: fuzzy zoeken in een venster

Mini.pick, met mini.extra erbij voor de extra bronnen. Beide zaten al in de
mini.nvim die de config laadt, dus dit kostte geen plugin. Volledige help:
`:h mini.pick` en `:h mini.extra`.

`:Pick <Tab>` toont alle bronnen. Het venster is 80% van het scherm en
gecentreerd; `Tab` klapt de preview open.

## De drie met een toets

- `<leader>f` — files: fuzzy over alle bestanden (via rg, respecteert .gitignore)
- `<leader>g` — grep_live: zoeken terwijl je typt. Dit is wat de cmdline
  niet kan; `:grep` blijft one-shot naar de quickfix
- `<leader>b` — buffers: springen tussen wat open is
- `<leader>j` — arglist: je vaste werkset, mét preview (navigatie.md).
  Mini.extra heeft die bron niet; het is `{ items = vim.fn.argv }`, het
  voorbeeld van een eigen source uit `:h MiniPick-source`

## Verder handig

- `:Pick help` — helppagina's; `:Pick oldfiles` — recent geopend
- `:Pick resume` — de vorige picker terug, inclusief je zoekterm

## In het venster

- `Tab` — preview aan/uit; `S-Tab` — info over het item
- `CTRL-N` / `CTRL-P` — omlaag/omhoog; `Enter` — kiezen
- `CTRL-S` / `CTRL-V` / `CTRL-T` — open in split, verticale split of tab
- `CTRL-Space` — verfijnen: de huidige treffers worden de nieuwe zoekbasis
- `CTRL-U` — regel wissen; `CTRL-R` — een register plakken; `Esc` — sluiten

## Naar de quickfix

Een picker kiest één ding; de quickfix is een wérklijst. De brug ertussen:

- `CTRL-X` — markeer het item onder de cursor (nog eens = demarkeren)
- `CTRL-A` — markeer álle huidige treffers, dus wat je zoekterm nú oplevert,
  niet de hele bron
- `ALT-Enter` — open de gemarkeerde items samen; zodra er bestanden of
  buffers tussen zitten wordt dat een quickfixlijst, die meteen opent

Daarmee wordt `<leader>g` een vulmachine voor de werkwijze uit workflow.md:
zoeken tot de treffers kloppen, `CTRL-A`, `ALT-Enter`, en dan `]q` of
`:cdo s/oud/nieuw/g | update` over de hele lijst.

Alt-Enter werkt hier doordat `option_as_alt = "Both"` in alacritty.toml
staat; zonder die instelling stuurt de Option-toets op macOS een teken in
plaats van een modifier.

De andere kant op kan ook: `:Pick list scope='quickfix'` bladert fuzzy door
een bestaande quickfixlijst — en net zo `scope='location'`, `'jumplist'` of
`'changelist'` (changelist.md).

## LSP en diagnostics

`:Pick lsp scope='...'` met een van: `document_symbol`, `workspace_symbol`,
`workspace_symbol_live`, `references`, `definition`, `declaration`,
`implementation`, `type_definition`.

Dit vult het gat uit lsp-keys.md: `workspace_symbol` en de call-functies
hadden geen toets omdat een kale lijst onhandig is. Met een picker erachter
zijn ze wél bruikbaar. `workspace_symbol_live` stuurt je zoekterm rechtstreeks
naar de server, dus dat schaalt ook in een groot project.

`:Pick diagnostic` toont alle diagnostics die nvim op dat moment kent. Bij
jdtls zijn dat vaak ook meldingen uit ongeopende projectbestanden; andere
servers publiceren mogelijk alleen voor open buffers. Nuttige opties:
`sort_by='severity'` zet fouten bovenaan, `scope='current'` beperkt tot deze
buffer. Moet je er een werklijst van maken voor `:cdo`: eerst filteren, dan
`CTRL-A` en `ALT-Enter` (workflow.md).

## Git

- `:Pick git_commits` — de historie; `:Pick git_hunks` — losse wijzigingen
- `:Pick git_files` — alleen wat git kent; `:Pick git_branches`

Fugitive blijft voor het echte werk (stagen, committen, blame): git.md.

## Naast de cmdline

De picker verving een eigen 'findfunc' die `:find` fuzzy maakte. Die is
eruit, dus `:find` en `:sf` doen nu niets bruikbaars meer. Wat bleef: `:b`
voor wat al open is, en `:grep` als je de treffers meteen als werklijst in
de quickfix wilt in plaats van in een venster.

Eén ding is stilletjes veranderd: mini.pick neemt `vim.ui.select` over, dus
keuzelijstjes van nvim zelf — code actions op `gra` bijvoorbeeld — verschijnen
nu ook in dit venster, en zijn dus fuzzy filterbaar.
