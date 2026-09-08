# Navigatie: hoe je ergens komt

buffers.md zegt wat er is; dit is hoe je springt — van dichtbij naar ver.

## Binnen een bestand

Vuistregel: spring gericht in plaats van j/k ingedrukt te houden.

- relativenumber: de cijfers in de kolom zíjn je tellers — `12j`, `8k`
- `f<teken>` — binnen de regel erheen (`F` terug); `;` herhaalt
- `/patroon` — zoeken, `n`/`N` verder (`*` — meteen het woord onder de cursor)
- `CTRL-L` — zoek-highlight weg én scherm ververst (nvim-default; in de
  verkenner ververst hij de listing)
- `%` — naar de bijbehorende haak
- `{` / `}` — per blok (lege regels); `[[` / `]]` — per sectie of def/class
- `g;` — terug naar waar je laatst typte (nog eens = verder terug; changelist.md);
  `gi` gaat er meteen in insert verder
- `gO` — outline (lsp-keys.md); folds als springstructuur: folds.md

## Tussen plekken: de jumplist

Elke grote sprong wordt onthouden — `CTRL-]`, een picker, `gg`/`G`, een
zoekactie. `CTRL-O` wandelt ze terug, `CTRL-I` (= Tab) weer vooruit, ook over
bestandsgrenzen heen. Navigeren sluit niets: buffers blijven gewoon geladen.
(`CTRL-T` is de specifiekere terug-na-`CTRL-]`, langs de tagstack.)

## Naar een ander bestand

- `<leader>f` — fuzzy over alle bestanden in de cwd, met preview op `Tab`;
  `CTRL-S` / `CTRL-T` openen in een split of tab (pick.md)
- `<leader>b` — springen naar iets dat al open is; `<leader>g` — zoeken op
  inhoud
- een pad uittypen (`:e`, `:r bestand`, …): de `**`-wildcard —
  `:e **/naam<Tab>` completeert recursief (:h starstar-wildcard). Verder
  neemt `:e` een letterlijk pad, en dat hoort zo: `:e nieuw.md` moet een
  niet-bestaand bestand kunnen maken — en bestaat de máp nog niet, dan maakt
  `:w ++p` die bij het opslaan aan (:h ++p). Met bestandsnaam kan ook:
  `:w ++p pad/kopie.md` schrijft een kopie, `:sav ++p pad/bestand.md`
  verhuist je buffer erheen

## Vaste bestanden: de arglist

Vims oudste werkset-mechanisme: bij `vim a.txt b.txt` zíjn die bestanden de
argumentenlijst. Naast de bufferlijst ("alles wat open is geweest") is dit de
korte, geordende lijst "waar ik nú aan werk", met een positie-aanwijzer — de
`[]` in `:args`. Als harpoon, met een dun laagje eromheen:

- `<leader>h` — open of sluit het menu: de lijst als buffer, één pad per regel.
  Daarin `a` om het bestand waar je vandaan kwam achteraan te zetten, `dd` om
  een slot te wissen, `<C-j>` / `<C-k>` om te verschuiven en `l` om te openen.
  Sluiten schrijft de lijst terug, hoe je ook sluit (config/arglist.lua).
  Lege regels verdwijnen en dubbele paden worden samengevoegd; `l` blijft
  het gekozen bestand openen. Een lange lijst scrollt binnen het scherm
- `CTRL-1` … `CTRL-6` — spring direct naar bestand 1 t/m 6; het slot waar je
  al in zit doet expres niets, want dat zou het bestand herlezen en je folds
  wissen (folds.md); `]a` / `[a` — volgende/vorige in de lijst (ingebouwd,
  zelfde familie als ]q en ]l)
- `:args` — toon de lijst op één regel (het huidige bestand staat tussen []);
  `:Pick arglist` toont hem als picker, met preview (pick.md)
- `:argdo {cmd}` — voer iets uit op élk bestand in de lijst: "Execute {cmd}
  for each file in the argument list" (:h :argdo). Dus
  `:argdo %s/oud/nieuw/g | update` over je hele werkset, en met een range
  (`:2,4argdo …`) over een deel ervan. Wat `:cdo` voor de quickfix is
- verwijderen: `:argd <Tab>` — de completion bladert door de lijst;
  `:%argdel` wist hem in één keer (:h :argdelete)

Heb je in deze map ooit `:SessionCreate` gedaan, dan overleeft de werkset het
afsluiten: de sessie schrijft de arglist mee weg, inclusief welk slot het
huidige was. Zonder sessie begin je elke start met een lege lijst (sessie.md).
Ook bij `:qa` met het menu open gaan de laatste menu-edits mee. Het huidige
argument blijft bij herschikken behouden zolang je het niet verwijdert, zonder
het bestand opnieuw te openen. `:arglocal` wordt in het oorspronkelijke venster
bijgewerkt; spaties en speciale tekens in paden blijven letterlijk behouden.

De lijst leeft per nvim-instantie, in het geheugen, maar de projectsessie
bewaart hem. Start je later `nvim` zonder argumenten in dezelfde cwd, dan komt
de arglist terug; een eenmalige start met een argument begint met een nieuwe
lijst. Een `:cd` breekt hem niet: nvim herschrijft de paden relatief aan de
nieuwe cwd, dus ze blijven wijzen waar ze wezen. Cursorposities kloppen
gewoon, dat doet de laatste-positie-autocmd al.

## Heen en weer

`<leader>i` — de alternate-buffer: pendelen tussen twee bestanden
(zie buffers.md).

## De ]-familie: vier lijsten, één grammatica

- `]q` / `[q` — quickfix (compilerfouten, :grep, grr)
- `]l` / `[l` — location list (gO-outline)
- `]d` / `[d` — diagnostics in de buffer
- `]a` / `[a` — de arglist (je vaste bestanden)

Zelfde beweging, andere lijst; hoofdletters (`]Q`, `[D`, …) springen naar
laatste/eerste.

## Onder de cursor

- `gf` — open het bestand waarvan de naam onder de cursor staat
  (`CTRL-W f` voor een split)
- `gx` — open de URL of het bestand extern, in de standaard-app
