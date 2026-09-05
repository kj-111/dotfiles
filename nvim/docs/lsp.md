# LSP: hoe het werkt in deze config

Een language server is een los programma per taal (jdtls, clangd, …) dat naast
nvim draait: in feite een compiler-frontend die aanblijft. Hij houdt jouw code
permanent geparsed in het geheugen (nvim stuurt bij elke wijziging de
bufferinhoud door) en doet daar twee soorten dingen mee:

- uit zichzelf: diagnostics pushen — fouten en waarschuwingen terwijl je
  typt, dus vóór je compileert of runt
- op verzoek van nvim: completion (blink vraagt), hover-documentatie (K),
  definitie (CTRL-]), references (grr), rename (grn), signature help
  (CTRL-S), formatteren (conform), code actions

Het protocol daartussen is LSP; alle toetsen staan op een rij in lsp-keys.md.

## Wat nvim standaard al doet

Niets hiervan staat in de config, want het zít er al (:h lsp-defaults) —
zodra een server attacht:

- de toetsen: `gra`, `gri`, `grn`, `grr`, `grt`, `grx`, `gO`, `K`,
  insert-mode `CTRL-S`, en `an`/`in` (lsp-keys.md)
- 'tagfunc' — daarom werkt `CTRL-]` (en heel :tag) via de server
- 'omnifunc' — kale completion op `CTRL-X CTRL-O`, ook zonder blink
- 'formatexpr' — `gq` formatteert de regels via de server
- diagnostics staan aan (de weergave stellen wíj in via
  `vim.diagnostic.config()` in config/lsp.lua)
- `gx` op een import volgt de documentLink van de server
- semantic tokens: de server kleurt code semantisch bij, bovenop treesitter
  (:h lsp-semantic_tokens)
- kleuren in code (bijv. CSS-hexwaarden) worden gemarkeerd. Dynamisch
  bestandswijzigingen watchen staat hier uit: Neovims recursieve macOS-watcher
  kan `EMFILE` raken. Open buffers blijven gewoon synchroniseren; na externe
  project- of buildwijzigingen gebruik je `:lsp restart` (Java eventueel
  `:JdtUpdateConfig`)

Vijf features laat nvim default úit: inlay hints, codelens, linked editing
range, inline completion en on-type formatting. config/lsp.lua zet ze
expliciet op die default. `:InlayHints` zet inlay hints globaal aan of uit;
voor alleen de huidige buffer kan het rechtstreeks met
`:lua vim.lsp.inlay_hint.enable(true, { bufnr = 0 })`. (De zesde opt-in is
native completion — die rol vervult blink hier.)

## Hoe nvim een server vindt en start

1. `lsp/<naam>.lua` beschrijft één server; `config/lsp.lua` scant die map en
   meldt alles aan met `vim.lsp.enable()`.
2. Open je een bestand met een passende filetype, dan zoekt nvim omhoog naar
   een `root_marker` uit de config (pyproject.toml, .stylua.toml, .git, …) om
   de projectroot te bepalen, en start daar de server. Een geneste lijst geeft
   markers gelijke prioriteit: dan wint de dichtstbijzijnde match.
3. De binary wordt op naam gevonden via PATH — installatie via brew, zie
   tools.md.

Uitzondering: java. jdtls start niet via lsp/, maar via `config/jdtls.lua`
(eigen workspace per project en projectinstellingen).

Doet een server het niet: `:checkhealth vim.lsp` — toont welke clients
draaien (met root en buffers), welke configs er zijn en waar het logbestand
staat. Hangt hij: `:lsp restart` herstart de clients van deze buffer
(:h lsp-commands).

## Voorbeeld: `nvim src/Speler.java`

1. nvim herkent filetype java; de FileType-autocmd van `config/jdtls.lua`
   vuurt
2. rootbepaling, omhoog vanaf het bestand, in twee rondes: eerst `.java-root`,
   `mvnw`, `gradlew`, `settings.gradle` (markeren de échte projectroot, zodat
   een submodule-pom.xml niet wint), dan pas `pom.xml`/`build.gradle`.
   Niets gevonden → melding: doe `touch .java-root` in de projectmap
3. de jdtls-binary wordt via PATH gevonden (brew); elke projectroot krijgt een
   eigen workspace-map in `~/.cache/nvim/jdtls-workspace/<naam>-<hash>`
4. ligt er `.settings/org.eclipse.jdt.core.prefs` (jinit levert die mee), dan
   gaan die projectinstellingen mee als formatteer- en codestijl
5. de server start, indexeert, en attacht — het 󰰎-icoon verschijnt in de
   statusline; K, CTRL-], grr en grn werken nu
6. bij `:w` formatteert jdtls via de conform-fallback, met de prefs uit stap 4
7. en jdtls compileert er automatisch bij: incrementeel, naar `out/` — dat
   staat in de `.classpath` die jinit meelevert (`src` → `out`). Na een save
   is `java -cp out Main` dus direct up-to-date; `:make` (javac, zelfde
   layout) blijft voor als je de compilerfouten in de quickfix wilt

## De lsp/-map

Elk bestand is de config van één server, met dezelfde bouwstenen:

- `cmd` — hoe de binary heet en start
- `filetypes` — waarvoor hij aangaat
- `root_markers` — wat een projectroot markeert
- `settings` — serverspecifieke opties (bijv. basedpyright's typeCheckingMode)

Bestand toevoegen = server erbij; verwijderen = server weg. Welke server er
voor een taal bestaat: de officiële lijst waar :h lsp-quickstart ook naar
wijst — https://microsoft.github.io/language-server-protocol/implementors/servers/
(installeren via brew, zie tools.md). Gedeelde zaken
(completion-capabilities via blink, de macOS-watcherbeperking en
diagnostics-weergave) zet `config/lsp.lua` in één keer voor alle servers via
`vim.lsp.config('*', …)`. Jdtls krijgt expliciet dezelfde capabilities omdat
nvim-jdtls zelf `vim.lsp.start()` gebruikt.

## Clangd: eigen config voor C

De clangd-rootmarkers staan als één groep met gelijke prioriteit. Daardoor
wint de dichtstbijzijnde projectmarker; een Makefile houdt een klein C-project
dus binnen zijn eigen map in plaats van terug te vallen op bijvoorbeeld
`~/academia/.git`.
`.clang-format` is bewust géén rootmarker: de globale symlink
`~/.clang-format` zou anders van je hele home één C-workspace maken. Clangd
vindt die opmaakconfig onafhankelijk van de LSP-root nog steeds.

`clangd/config.yaml` geldt voor elk project zonder eigen
`compile_commands.json` of `.clangd` — precies de situatie bij losse
oefenbestanden. Zonder dat bestand raadt clangd de compileflags en zwijgt hij
over dingen waar de compiler wél over klaagt; je ziet de fout dan pas bij het
compileren in plaats van tijdens het typen.

Het is puur voor de LSP. Clangd leest het, `clang` in de terminal niet. Houd
de flags daarom gelijk aan wat je daar typt, anders klaagt nvim over andere
dingen dan je compiler:

```
clang -std=c23 -Wall -Wextra bestand.c -o bestand && ./bestand
```

Een Makefile helpt daar niet bij: die is voor `make`, clangd leest hem niet.
Clangd wil een `compile_commands.json`, en die maakt een gewone Makefile
niet. Vandaar dat je in je C-projecten dit ziet:

```
Failed to find compilation database for .../hallo.c
clang -std=c23 -Wall -Wextra          ← komt uit clangd/config.yaml
```

Juist omdat je met Makefiles werkt is dit bestand dus nodig. Wil je clangd
je echte build laten volgen, dan schrijft `bear -- make` de database mee —
voor oefenprojecten van één bestand is dat overkill.

Zonder `-std=c23` valt clang terug op C17 (`__STDC_VERSION__` is dan
`201710`) en keurt nvim C23-syntax af die je Makefile wél compileert. Een
kale `bool` zonder `stdbool.h` is het duidelijkste voorbeeld.

Let op als je ooit een project mét een eigen `compile_commands.json` of
`.clangd` opent: de vlaggen hieruit komen dan áchter die van het project, en
bij een herhaalde `-std=` wint de laatste. Getest — een project dat `c11`
opgeeft krijgt alsnog `c23`. `Remove: -std=*` in het project helpt niet,
want deze `Add` komt daarna. De uitweg is dan `-std=c23` hier tijdelijk
uitzetten. Zolang al je C-projecten op c23 bouwen, zoals nu, merk je er
niets van.

Daarnaast staat clang-tidy aan, dat vangt wat de compiler laat passeren:
verkeerde `sizeof`, vergeten `free`, verdachte vergelijkingen. Drie checks
staan expliciet uit omdat ze bij oefenwerk vooral ruis geven —
`bugprone-easily-swappable-parameters` klaagt over elke functie met twee
parameters van hetzelfde type, en `readability-magic-numbers` en
`readability-identifier-length` willen overal constanten en lange namen.

Let op de vindplaats: clangd zoekt op macOS in
`~/Library/Preferences/clangd/`, niet in `~/.config/clangd/`. Het werkt hier
via een symlink, en verdwijnt die, dan wordt het bestand stil genegeerd. Je
merkt het doordat waarschuwingen wegblijven die de compiler wél geeft.

## Formatters (conform, bij :w)

Python doet ruff, lua stylua, javascript/json/markdown prettierd. De rest
valt terug op de LSP: java via jdtls, c via clangd. Welke tool bij welke taal
hoort en waar elke config staat: formatteren.md.
