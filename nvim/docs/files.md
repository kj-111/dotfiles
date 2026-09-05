# Mini.files: de verkenner in kolommen

Zat al in de mini.nvim die de config laadt, dus dit kostte geen plugin.
Volledige help: `:h mini.files`; in de verkenner toont `g?` alle toetsen.

Een map is een buffer, net als bij oil, maar je ziet de hele tak naast
elkaar in kolommen in plaats van één map. Bewerken ís bestandsbeheer, en
`=` voert het uit — met een bevestigingsdialoog die opsomt wat er gaat
gebeuren.

## Openen en navigeren

- Pad al bekend: open rechtstreeks met `:e dir/bestand` in plaats van eerst
  door mini.files te navigeren; Tab vult padonderdelen aan
- Config aanpassen: `:e $MYVIMRC` opent meteen het actieve vimrc-bestand
- `<leader>e` — openen op het huidige bestand, nog eens = sluiten
- `nvim .` of `:e map/` — een map openen ís mini.files (use_as_default_explorer)
- `l` — de map in of het bestand openen; `h` — een niveau terug
- `L` — als `l`, maar sluit de verkenner meteen bij een bestand
- `q` — sluiten; `<BS>` — terug naar de begintoestand
- `<` / `>` — kolommen links of rechts wegtrimmen; `@` — spring naar de cwd

## Bewerken = bestandsbeheer

Typ, hernoem en verwijder alsof het tekst is; pas `=` voert het uit.

- nieuw bestand: naam op een nieuwe regel; nieuwe map: naam op `/` laten eindigen
- hernoemen: pas de regel aan
- verwijderen: `dd`; kopiëren of verplaatsen: `yy`/`dd` in de ene kolom, `p`
  in de andere
- `=` — synchroniseren, met bevestiging. Lees die lijst: dit is het punt
  waarop het écht gebeurt
- vóór `=` is niets definitief; `u` maakt je bewerking gewoon ongedaan

Aanmaken, hernoemen en verwijderen worden aan de LSP gemeld, dus imports
schuiven mee. Voor code blijft `grn` toch de route, zie onder.

## Verwijderen gaat naar een prullenbak

`permanent_delete` staat hier op `false`, dus verwijderde bestanden gaan
naar een eigen prullenbakmap van mini.files (in nvim's data-dir), niet naar
de macOS-prullenbak. Terugzetten doe je dus niet via Finder maar door het
bestand daar vandaan te halen; `:h mini.files` noemt het pad.

## Code hernoemen: grn in de buffer, niet hier

Hernoemen hier verhuist het bestand en laat de LSP imports bijwerken, maar
bij Java blijft de classnaam ín het bestand achter (compileerfout). Daarom:
cursor op de classnaam in de code en `grn` — jdtls doet classnaam,
bestandsnaam én elke verwijzing in één keer. Hernoemen in de verkenner
alleen voor bestanden waar niets naar verwijst (notities, configs).

## Geen boom

Kolommen tonen de tak waarin je zit, geen uitklapbare boom over het hele
project. Overzicht haal je uit `<leader>f` (fuzzy over alle bestanden) en
`<leader>g` (zoeken op inhoud) — zie pick.md. Een boom is hier twee keer
geprobeerd, met netrw en nvim-tree, en beide keren weer weggehaald.

Wil je er tóch één, dan is dat werk voor de shell en niet voor de editor:

```
tree --gitignore -d      pakketstructuur van een Java-project
tree --gitignore -L 2    twee niveaus diep, bestanden erbij
```

`--gitignore` is hier de hele truc: `out/` en `target/` staan al in je
gitignore, dus de gecompileerde klassen vallen vanzelf weg en je houdt de
pakketindeling over. Zonder die vlag verdubbelt de boom.
