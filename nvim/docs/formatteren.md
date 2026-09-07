# Formatteren: welke tool, en waar zijn config staat

Conform draait bij elke `:w` (`lua/config/format.lua`). Talen zonder eigen
formatter vallen terug op de LSP, via `lsp_format = 'fallback'`.

| taal                     | formatter                      | config                       |
| ------------------------ | ------------------------------ | ---------------------------- |
| python                   | ruff, eerst imports dan opmaak | `ruff/ruff.toml`             |
| lua                      | stylua                         | `nvim/.stylua.toml`          |
| javascript/json/markdown | prettierd                      | `prettier/.prettierrc`       |
| c                        | clangd (LSP-fallback)          | `clang-format/.clang-format` |
| java                     | jdtls (LSP-fallback)           | `.settings/` in het project  |
| rust                     | rustfmt                        | project-`rustfmt.toml`       |

Voor c en java staat er niets in conform: die servers formatteren zelf. Bij
clangd zit de motor (LLVM's libFormat) ín de server, dus `clang-format` hoeft
niet apart geïnstalleerd — zie tools.md.

Rustfmt draait rechtstreeks via conform; rust-analyzer is alleen de fallback.
In een Cargo-project haalt conform de edition uit `Cargo.toml` en een
projectgebonden `rustfmt.toml` of `.rustfmt.toml` wint vanzelf. Voor een los
`.rs`-bestand gebruikt de config edition 2024 en verder de standaard Rust-stijl.

## Hoe elke tool zijn config vindt

Drie verschillende mechanismen, en dat is geen slordigheid: het is wat elke
tool ondersteunt.

Ruff zoekt `~/.config/ruff/ruff.toml` zelf op. Dat geldt dus ook voor een los
scriptje in `/tmp`.

Stylua loopt omhoog vanaf het bestand en vindt `nvim/.stylua.toml` binnen de
nvim-map.

Prettierd valt terug op `PRETTIERD_DEFAULT_CONFIG` (zshrc) als het omhoog
zoeken niets oplevert. Wijzig je die config, dan moet de daemon zijn omgeving
opnieuw lezen: `prettierd restart`.

Clang-format kent géén gebruikersconfig. Hij loopt alleen omhoog vanaf het
bestand en stopt daar — nagemeten: een bestand in `/tmp` kreeg kale
LLVM-stijl terwijl `~/.clang-format` bestond. Daarom staat de echte file in
de repo en wijst `~/.clang-format` ernaartoe met een symlink. Verdwijnt die,
dan valt alles stil terug op LLVM: 2 spaties en `int *p`. `--fallback-style`
van clangd is geen alternatief — die neemt wel een stijlnaam (`Microsoft`,
`Google`, getest) maar negeert `file:<pad>` zonder foutmelding.

In alle gevallen wint een config ín een project van de globale.

## Ruff

Ruff is linter, importsorteerder, formatter én taalserver in één binary. Vier
kanalen lezen hetzelfde bestand: `ruff server` (de LSP in nvim),
`ruff_organize_imports` en `ruff_format` (conform bij `:w`), en `ruff check`
op de commandoregel. Getest door `SIM` toe te voegen — die regel dook meteen
op als diagnostic in nvim, dus de server leest dezelfde gebruikersconfig.

De selectie is `E, F, I, UP, B, C4, SIM, RUF`. E en F zijn de kern
(pycodestyle en pyflakes), de rest is nagemeten op eigen scripts: samen
leverden ze twaalf treffers, waaronder een ongedefinieerde naam (F821) en een
bestand dat zonder context manager geopend werd (SIM115). Ruff's eigen repo
selecteert vrijwel dezelfde set.

Twee regels staan op ignore:

- `E501` — regellengte laat je aan de formatter over, anders melden linter en
  formatter allebei iets over dezelfde regel. Ruff's eigen repo verwoordt het
  zo: "Leave it to the formatter to split long lines and the judgement of all
  of us."
- `B905` — `zip()` zonder `strict=`. Bedoeld tegen stil afkappen (zip stopt
  bij de kortste lijst), maar het meldt bij élke zip. Weet je het niet zeker,
  dan blijft `strict=True` de veilige schrijfwijze.

`target-version` is `py314`, gelijk aan de python die hier draait. Dat stuurt
wat `UP` mag herschrijven; op de huidige code maakt py313 of py314 nog geen
verschil, maar hij hoort mee te lopen met de interpreter.

`line-length = 88` is voor de formatter een streefwaarde, geen harde grens.
Ruff splitst code waar dat veilig kan, maar herschrijft gewone comments niet
automatisch over meerdere regels. Dat is een bewuste formatterkeuze: Ruff's
FAQ zegt dat hij automatic line-wrapping vermijdt "in some cases (e.g., within
comments)". Anders dan jdtls voor Java heeft Ruff dus geen commentformatter
die prozaregels op 88 tekens afbreekt; lange Python-comments splits je zelf.

`extend-exclude = [".venv", ".idea"]` geldt voor linten én formatteren.
`.venv` zit al in Ruff's standaard-excludes en staat hier dus bewust expliciet;
`.idea` is de eigen aanvulling. `extend-exclude` voegt ze toe zonder Ruff's
ingebouwde lijst te vervangen.

Van de formatter zijn er maar twee afwijkingen van de defaults:

- `quote-style = "single"` — de bestaande scripts staan vol enkele quotes en
  prettier doet voor javascript hetzelfde. Gemeten: met `double` zou de
  formatter zo'n 280 regels extra aanraken, puur quote-omzetting.
- `docstring-code-format = true` — standaard uit; formatteert codevoorbeelden
  ín docstrings. Raakt de huidige bestanden niet.

Let op waar een optie hoort: `line-length` en `indent-width` staan top-level
en voeden linter én formatter. `indent-style`, `quote-style`, `line-ending`,
`skip-magic-trailing-comma` en `docstring-code-format` horen onder
`[format]`.

Die lijst is zo goed als compleet — ruff heeft negen `[format]`-opties, en
maar zes daarvan gaan echt over stijl. Dat is geërfd van black: weinig
knoppen, zodat de discussie ophoudt. Clang-format heeft er meer dan honderd.

## Clang-format

De stijl blijft dicht bij LLVM: 80 kolommen, accolade op dezelfde regel,
spatie na `if` maar niet na een functienaam.

Twee afwijkingen en drie keuzes die het uitleggen waard zijn:

- `IndentWidth: 4` — LLVM staat op 2, wat bij genest C-werk te weinig is om
  de niveaus uit elkaar te houden
- `IndentCaseLabels: true` — LLVM zet `case` op dezelfde hoogte als de
  `switch` eromheen, waardoor de labels en de body van de switch optisch één
  blok worden. Ingesprongen loopt de trap gewoon door: switch, case, statement
- `InsertBraces: true` — altijd accolades, ook bij een `if` van één regel.
  C-specifiek: zonder accolades leidt een tweede regel erbij tot een fout die
  je niet ziet
- `SortIncludes: Never` — in C kan de volgorde van headers betekenis hebben
- `DerivePointerAlignment: false` — die staat standaard áán en zou de
  pointerstijl per bestand overnemen van wat er al staat. Precies wat je niet
  wilt als je een vaste stijl afspreekt

## Waarom de configs zelf kaal zijn

Alle uitleg staat hier, niet in de configbestanden. Dat scheelt twee plekken
die uit elkaar gaan lopen — de reden achter `B905` of `SortIncludes` hoort op
één plaats te staan.

Wat er wél bovenin een config staat is het symlink-commando, bij
`.clang-format` en bij `clangd/config.yaml`. Die twee falen stil: raakt de
symlink weg, dan wordt het bestand genegeerd zonder foutmelding en merk je
het pas aan de inspringing of aan waarschuwingen die wegblijven. Dat hoort
waar je kijkt, niet in een doc.

`clangd/config.yaml` zelf gaat niet over opmaak maar over compileflags en
clang-tidy; die uitleg staat in lsp.md.
