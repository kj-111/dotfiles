# Bewerken: de grammatica

Elke bewerking is operator × doel. Operators: `d` (delete), `c` (change),
`y` (yank), `>` (inspringen), `gu`/`gU` (case), `gc` (comment). Doelen: elke
beweging uit navigatie.md, of een textobject: `iw`/`aw` (woord), `i"`/`a"`
(string), `i(`/`a(` (haakjes), `ip`/`ap` (alinea/blok).

Samen: `ciw` (verander woord), `di"` (leeg de string), `yap` (yank het blok),
`>ip` (spring het blok in). En `.` herhaalt de hele bewerking op de volgende
plek — de gratis beloning van de grammatica.

## Registers en clipboard

- yank en delete delen één naamloos register — vandaar dat plakken na een
  delete "je yank kwijt" lijkt; `"0p` plakt de laatste yank, die blijft staan
- `"+y` / `"+p` — het macOS-clipboard (bewust niet automatisch gekoppeld)
- insert- of cmdline-mode: `CTRL-R +` plakt een register direct
- `:reg` — toon wat er in alle registers zit (mini.clue toont ze ook al bij
  het intypen van `"`)

## Herhalen

- `.` — herhaal de laatste bewerking
- macro's: `qa` … `q` neemt op in register a; `@a` speelt af, `@@` nog eens,
  `10@a` tien keer
- `:Undotree` — open de vertakte undo-historie. Toetsen zijn er niet: "while
  in the window, moving the cursor changes the undo" (:h package-undotree)

## Eigen toetsen en hulpjes

- `CTRL-J` / `CTRL-K` — regel (of selectie) een plek omlaag/omhoog
- `<` / `>` in visual mode — inspringen mét behoud van de selectie
- `gcc` — comment de regel; `gc` + doel volgt de grammatica (`gcip`)
- mini.pairs — sluit haakjes en quotes automatisch tijdens het typen
- `jk` — insert-mode uit
- selectie structureel uitbreiden: `an`/`in` (zie lsp-keys.md)
