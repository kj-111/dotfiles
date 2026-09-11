# kew

Muziekspeler voor in de terminal, voor lokale bestanden.

Setup op een nieuwe Mac:

```sh
brew install kew
mkdir -p ~/Library/Preferences/kew
ln -sf ~/.config/kew/kewrc ~/Library/Preferences/kew/kewrc
```

Die symlink moet echt. Op macOS leest kew zijn config uitsluitend uit
`~/Library/Preferences/kew/`, niet uit `.config` — dat staat zo in zijn
`src/ui/settings.c` en is nagemeten: zonder het bestand op die plek faalt
`kew path` met `fopen: No such file or directory` in `~/Library/Logs/kew/` en
schrijft hij nergens iets.

Alleen `kewrc` staat hier. De rest die kew aanmaakt blijft in Library, want dat
is state en cache: `kewstaterc` (in-app wijzigingen, gaan vóór op `kewrc`),
`library.dat` (mappenboom), `themes` en `layouts`.

De muziekmap staat al in `kewrc` en verzet je met:

```sh
kew path ~/Documents/archief/music
```

Kew zoekt op artiest, album en titel uit de tags, niet op bestandsnaam. Dus
`kew gracie` of `kew lofi` werkt, ook al heten de bestanden `45-slow-river.m4a`.

## Starten

```sh
kew                  # de bibliotheek
kew gracie           # alles wat matcht, als afspeellijst
kew play <pad>       # eenmalig, zonder de bibliotheek te wijzigen
kew --help
```

## In de speler

| toets                 | doet                                                                |
| --------------------- | ------------------------------------------------------------------- |
| `Space`               | pauzeren                                                            |
| `=` / `-`             | volume in stappen van 5% (`+` doet hetzelfde als `=`)               |
| `h` / `l`             | vorige en volgende track                                            |
| `a` / `d`             | terug- en vooruitspoelen                                            |
| `j` / `k`             | scrollen                                                            |
| `Enter`               | in de wachtrij; `Ctrl+g` meteen afspelen                            |
| `Tab`                 | volgende weergave; `Shift+Tab` terug                                |
| `Shift+x` / `Shift+z` | bibliotheek en afspeellijst                                         |
| `Shift+c` / `Shift+v` | track en zoeken                                                     |
| `Shift+b`             | alle toetsen                                                        |
| `.`                   | naar favorieten, opgeslagen als `kew favorites.m3u` in je muziekmap |
| `u`                   | bibliotheek opnieuw inlezen na nieuwe bestanden                     |
| `s` / `r`             | shuffle en repeat                                                   |
| `v`                   | visualizer                                                          |
| `q`                   | afsluiten                                                           |

Alle bindings staan onderin `kewrc` en zijn daar te wijzigen.

Albumhoezen komen er alleen als je terminal afbeeldingen kan tonen.
`coverStyle=auto` laat kew zelf kiezen: kitty gebruikt zijn graphics protocol,
Alacritty kan het niet en valt terug op blokken of braille.
