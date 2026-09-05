# LSP-toetsen

Allemaal Neovim-defaults (:h lsp-defaults); ze werken zodra
een server attacht. Hoe die keten werkt staat in lsp.md.

## Springen en lezen

- `K` — hover-documentatie; nóg eens K springt het venster in
- `CTRL-]` — naar de definitie (via 'tagfunc'); `CTRL-T` terug.
  Let op: `gd` is géén LSP — dat is het oude tekst-zoeken naar een lokale
  declaratie; de echte sprong is CTRL-]
- `grt` — naar de typedefinitie (van de variabele naar zijn klasse)
- `gri` — implementaties (interface → wie implementeert dit)
- `grr` — alle verwijzingen, in de quickfix
- `gO` — outline van het bestand, in de location list (`]l` / `[l`)

## Veranderen

- `grn` — rename: symbool, bestand én alle verwijzingen (zie files.md)
- `gra` — code actions (ook in visual mode): quick fixes, imports, refactors
- `grx` — codelens uitvoeren (bijv. "run test" boven een methode)

## Insert-mode

- `CTRL-S` — signature help: welke parameters, waar zit je. Nóg eens CTRL-S
  springt de float in: "if a popup with this id is opened, then focus it"
  (:h vim.lsp.util.open_floating_preview()). Daarbinnen is `K` géén hover meer
  — die mapping is buffer-lokaal en de float heeft geen client — dus valt K
  terug op 'keywordprg', standaard `:Man`. In C is dat toevallig nuttig
  (`printf`), elders krijg je "no manual entry". Weg met `q`
- completion komt van blink; het kale alternatief is `CTRL-X CTRL-O`

## Diagnostics

- `]d` / `[d` — volgende/vorige; `CTRL-W d` — detail in een float
- `<leader>d` — alle huidige diagnostics rechtstreeks in de quickfix; de lijst
  opent alleen als ze niet leeg is

## Selectie

- `an` / `in` in visual mode — selectie slim uitbreiden/verkleinen langs de
  code-structuur (expression → statement → blok)

## Documentatie van een library lezen

Vier routes, oplopend in hoeveel je te zien krijgt. Voorbeeld: `.map()` op een
Stream.

- `K` op `map` — de javadoc van die ene methode in een float; nog eens `K`
  springt erin
- `CTRL-]` op `map` — naar de bron van `java.util.stream.Stream`, en daar `gg`:
  bovenaan staat de klasse-javadoc, die uitlegt wat de methode-javadoc níét
  doet — waarom een stream lazy is en wat een terminal operation is. `CTRL-T`
  terug
- `CTRL-S` in insert mode tussen de haakjes — alleen de parameters
- `gx` op de importregel `import java.util.stream.Stream;` — de webjavadoc van
  die module (documentLink; servergebonden)

Springen naar de bron kan omdat de JDK zijn broncode meelevert in
`lib/src.zip`. Voor libraries van buiten doet `downloadSources` in jdtls.lua
hetzelfde.

## Zonder toets

Deze hebben geen keymap; via `:Pick lsp scope='workspace_symbol'` en
verwanten zijn ze het handigst (pick.md).

Compleet werkende functies waar nvim bewust geen default toets aan geeft;
aanroepen met `:lua vim.lsp.buf.…` (mappen kan later altijd):

- `workspace_symbol()` — symbolen zoeken door het hele project (de
  projectbrede broer van `gO`); vraagt een query, leeg = alles
- `incoming_calls()` / `outgoing_calls()` — call hierarchy: wie roept deze
  methode aan, en wie roept zíj aan (resultaat in de quickfix)
- `typehierarchy('supertypes')` / `('subtypes')` — de klassenhiërarchie
  op en af
- `document_highlight()` — andere gebruiken van het symbool onder de cursor
  oplichten; weg met `clear_references()`
