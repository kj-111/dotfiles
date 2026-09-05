# Buffers en vensters: wat sluit wat

Het model: een buffer is het geladen bestand, een venster is een kijkgat op
een buffer. Vensters sluiten raakt buffers nooit; buffers sluiten kan wél
vensters meenemen.

## Venster dicht (buffer blijft geladen)

- `:q` — dit venster dicht; is het het laatste, dan sluit nvim
- `CTRL-W q` — zelfde als `:q`, maar als toets
- `:close` — ook hetzelfde, maar weigert het laatste venster (E444) — de
  variant die nooit per ongeluk nvim afsluit

## Buffer weg (uit de sessie)

- `:bd` — buffer gelost en uit de lijst; een venster dat hem toont gaat
  dicht (behalve het laatste, dat een andere buffer krijgt). Ongesavede
  wijzigingen → weigert, `:bd!` gooit ze weg
- `:bw` — grondiger (wist ook marks en dergelijke); zelden nodig

Buffers blijven anders gewoon geladen: na `:e ander` is de vorige er nog —
`:ls` toont ze, `:b naam` haalt terug.

## Buffers openen: de familie

|                       | huidig venster | in een split       |
| --------------------- | -------------- | ------------------ |
| bestand, pad bekend   | `:e`           | `:sp` (`:vs`)      |
| bestand, fuzzy zoeken | `<leader>f`    | daarin `CTRL-V`    |
| buffer (al geladen)   | `:b`           | `:sb` (`:vert sb`) |

`:e` opent het getypte pad letterlijk, de picker zóekt (pick.md). Daarom
blijft `:e` bestaan naast de picker: een pad dat nog niet bestaat vindt hij
niet, maar `:e nieuw/pad/bestand.md` maakt het gewoon aan — de tussenmappen
maakt `:w ++p` bij het opslaan (navigatie.md).

Eens je werkset open is, wint `:b` het van de picker: minder keystrokes,
want hij zoekt alleen in de al geladen buffers — een stukje van de naam
volstaat (`:b setl`), Tab loopt de matches af. De picker is voor de éérste
keer openen; daarna is `:b` de kortste sprong.

De blokjes van `:vert sb term`: `sb` is de splitvariant van "open bestaande
buffer", `vert` maakt van de standaard horizontale split een verticale (werkt
voor elk split-commando; `:vs` ís gewoon `:vert sp`), en `term` is de naam —
een deel volstaat, terminalbuffers heten voluit `term://…//pid:/bin/zsh`.

`:vs b term` kan níet (`:vs` verwacht een bestandsnaam, geen commando); een
vérse terminal in een split is `:vs +term`, via het `+cmd`-argument.

## De alternate-buffer

`#` is de vorige buffer waar je zat. `:b#` springt ernaartoe, `CTRL-^` is
daar de toets voor — en `<leader>i` is daar onze map van. Drie spellingen
van hetzelfde: heen en weer tussen twee bestanden.

## Nvim afsluiten

`:q` sluit alleen dít venster, dus met splits ben je aan het klikken. In
één keer eruit is `:qa`, en je verliest niets: 'confirm' staat aan, en dan
"raise a dialog asking if you wish to save" in plaats van te weigeren
(:h 'confirm'). Je krijgt dus per gewijzigd bestand de vraag.

Twee assen: hoevéél sluit het (de `a` van all), en schríjft het (de `w`).

|        | bereik      | schrijft          | bij wijzigingen |
| ------ | ----------- | ----------------- | --------------- |
| `:q`   | dit venster | nee               | vraagt          |
| `:q!`  | dit venster | nee               | gooit weg       |
| `:wq`  | dit venster | ja, altijd        | slaat op        |
| `:qa`  | heel nvim   | nee               | vraagt          |
| `:wqa` | heel nvim   | alleen gewijzigde | slaat op        |
| `:qa!` | heel nvim   | nee               | gooit alles weg |

`ZZ` is `:x`: schrijft "only when changes have been made" (:h :xit), waar
`:wq` altijd schrijft. Bij Java scheelt dat een formatteer- en
compileerronde van jdtls. `ZQ` is `:q!`. Voor de all-variant maakt het niet
uit: `:wqa` en `:xa` zijn hetzelfde commando.

Een lopende `:term` houdt je niet tegen: anders dan Vim vraagt nvim niets
over de job, hij sluit gewoon af. En je splits hoef je niet te sparen — bij
het afsluiten wordt de sessie bewaard, dus `nvim` in dezelfde map zet je
layout, buffers en arglist terug (sessie.md).
