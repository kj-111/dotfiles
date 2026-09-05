# Notities in markdown

Markdown is het enige bestandstype hier waar de tekst zelf het doel is en
niet de structuur eromheen. Daarom staan de instellingen anders dan bij
code: regels lopen door, autopairs is uit, en de opmaak wordt getekend in
plaats van getoond.

## De opmaak zelf, kort

| je typt           | je krijgt                                                          |
| ----------------- | ------------------------------------------------------------------ |
| `# Titel`         | kop 1; `##` tot `######` gaan dieper                               |
| `- item`          | opsomming; twee spaties inspringen nest hem                        |
| `1. item`         | genummerd — prettier hernummert zelf, dus `1.` overal mag          |
| `- [ ]` / `- [x]` | open en afgevinkte taak                                            |
| `**vet**`         | vet, `_cursief_` cursief                                           |
| `` `code` ``      | code in de tekst                                                   |
| ` ```java `       | codeblok; de taal erachter geeft kleuring                          |
| `[tekst](url)`    | link                                                               |
| `> citaat`        | blokcitaat                                                         |
| `> [!NOTE]`       | gekleurde callout — ook `[!TIP]` en `[!WARNING]`                   |
| `---`             | horizontale streep                                                 |
| `\| a \| b \|`    | tabelrij; een regel `\| --- \| --- \|` eronder maakt het een tabel |

Koppen zijn hier het belangrijkst: `gO` bouwt er de inhoudsopgave uit op,
`]]` springt ertussen, en `zM` klapt je notitie ertoe dicht. Structuur met
`#` is dus meteen navigatie.

De meeste hiervan tekent render-markdown weg — je ziet het icoon en niet de
sterretjes. `<leader>v` zet dat uit als je de ruwe tekst wilt zien.

## Wat nvim zelf al doet

`markdown` is een van de weinige filetypes met een echte ftplugin in de
runtime, en die is niet mager (`:h ft-markdown-plugin`):

- `gO` opent de inhoudsopgave van het bestand, gebouwd op treesitter
- `]]` / `[[` springen naar de volgende/vorige kop
- `'commentstring'` is `<!-- %s -->`, dus `gcc` werkt zoals overal
- `'formatlistpat'` kent genummerde en opsommingslijsten, dus `gq`
  herformatteert een alinea in een lijstitem zonder de bullet te slopen
- `'expandtab'` en `shiftwidth=4` staan al goed; wil je dat niet, dan is
  `g:markdown_recommended_style = 0` de knop

Vouwen staat standaard uit in die ftplugin (`g:markdown_folding`), maar
dat maakt hier niet uit: treesitter levert `'foldexpr'` al voor elk
filetype, dus `zM` klapt de notitie dicht tot een lijst koppen.

## after/ftplugin/markdown.lua

Twee dingen bovenop de runtime-ftplugin.

Doorlopende regels. `'wrap'` staat globaal uit (set.lua) omdat dat voor
code klopt; voor proza niet. Met `'linebreak'` breekt hij op een spatie
en niet middenin een woord, en `'breakindent'` houdt het vervolg
uitgelijnd onder een bullet. `j` en `k` worden `gj`/`gk`, maar alleen
zonder teller: `5j` blijft vijf echte regels, zodat `relativenumber` blijft
kloppen.

Autopairs uit, via `vim.b.minipairs_disable = true`. In code is
automatisch sluiten winst, in proza is het ruis — elke `(` en elke `"` die
je typt krijgt ongevraagd een partner.

## render-markdown.nvim

Tekent de opmaak in de buffer met extmarks: koppen krijgen een icoon en
een achtergrond, `**vet**` wordt vet zonder de sterretjes, tabellen
krijgen randen, checkboxes een vinkje, en GitHub-callouts
(`> [!NOTE]`) een gekleurde balk.

De plugin zet zelf `'conceallevel'` op 3 — "Concealed text is completely
hidden" — want zonder verbergen blijft de ruwe syntax naast het icoon
staan.

Onze afwijking van de default staat in `lua/config/render_markdown.lua`:

```lua
anti_conceal = { enabled = false },
```

Default toont render-markdown de ruwe tekens weer zodra je cursor op die
regel staat, door `'concealcursor'` leeg te laten — dat is precies het
gedrag dat de help zelf aanraadt ("A useful value is `nc`"). Met
`anti_conceal` uit zet de plugin `'concealcursor'` op `nvic`: de opmaak
blijft staan in élke modus. Het beeld springt dus nooit onder je cursor
weg terwijl je typt, maar je ziet ook nooit de ruwe `[tekst](url)` van de
regel waar je in zit. Wil je die even zien: `<leader>v` zet de hele
weergave uit en weer aan.

`latex` staat uit. Die regel moet er expliciet staan: de default van
`latex.enabled` is `true`, dus hem weglaten zet het juist aan. De renderer
zoekt dan naar `utftex` of `latex2text` en die staan hier niet.

De plugin doet zijn eigen `setup()` al vanuit `plugin/render-markdown.lua`
bij het opstarten. Onze `setup()` in de config is dus geen lazy-load maar
gewoon de tweede aanroep, die onze opties erin merget.

## Snippets

Geen extra plugin. blink.cmp heeft `snippets` al in zijn standaard
bronnenlijst staan (`lsp, path, snippets, buffer`) en die bron scant
vanzelf `~/.config/nvim/snippets/`. Een bestand `markdown.json` erin
neerzetten is genoeg — de bestandsnaam is het filetype.

Het formaat is dat van VS Code: een prefix, een body, en `${1:...}` voor
de tabstops.

```json
{
    "link": {
        "prefix": "link",
        "body": "[${1:tekst}](${2:url})",
        "description": "Inline link"
    }
}
```

Uitvouwen gaat via `vim.snippet` (`:h vim.snippet`), de ingebouwde
implementatie; blink roept die alleen aan. Met de `super-tab`-keymap
accepteert Tab de suggestie, en zolang de sessie loopt springt Tab naar de
volgende tabstop en Shift-Tab terug.

Wat er nu in `snippets/markdown.json` staat:

| prefix  | doet                                     |
| ------- | ---------------------------------------- |
| `code`  | fenced codeblok, taal als eerste tabstop |
| `table` | tabelskelet                              |
| `note`  | callout `> [!NOTE]`                      |
| `tip`   | callout `> [!TIP]`                       |
| `warn`  | callout `> [!WARNING]`                   |
| `todo`  | `- [ ]`                                  |
| `date`  | datum van vandaag                        |

Alleen wat je met de hand niet sneller typt. Een link of een afbeelding
zijn twee haakjes, daar is een snippet omslachtiger dan het typewerk.

`date` gebruikt `$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE`. Blink vult
een hele reeks van die variabelen in, onder meer `CURRENT_DAY_NAME`,
`TM_FILENAME_BASE`, `CLIPBOARD` en `UUID`.

Twee dingen om op te letten als je er zelf bij schrijft. Een letterlijke
`$` moet je escapen als `\$`, anders leest de parser hem als het begin van
een variabele en vouwt het snippet niet uit. En de prefixes zijn gewone
woorden (`note`, `table`, `date`), die je in proza ook typt; dat botst niet
hard omdat blink snippets een `score_offset` van -4 geeft en ze dus onder
de gewone buffertreffers zet.

Een `all.json` in dezelfde map zou in élk filetype meekomen; die is er
bewust niet.

## Formatteren

`markdown = { 'prettierd' }` in conform (`lua/config/format.lua`).
prettierd stond er al voor javascript en json, dus dit kost geen nieuwe
tool.

Wat hij bij het opslaan doet, gemeten op een rommelig bestand:

- tabellen uitlijnen — je typt de pipes slordig, ze komen recht te staan
- lijstmarkers gelijktrekken naar `-`, en nesting op de juiste diepte
- `1)` `2)` wordt `1.` `2.`
- `__vet__` wordt `**vet**`, `*cursief*` wordt `_cursief_`
- dubbele spaties in een zin weg, trailing spaties weg
- `***` als scheidingslijn wordt `---`
- spaties uit een link-URL: `[x]( url )` wordt `[x](url)`
- de inhoud van een codeblok formatteren in de taal van de fence — een
  blok met `js` erachter komt er als javascript uit

Alinea's blijft hij af: prettier staat standaard op `proseWrap:
"preserve"`, dus je eigen regelafbreking blijft zoals je hem zette. Ook
setext-koppen (`Titel` met `=====` eronder) laat hij staan.

Waar de instellingen vandaan komen: prettier loopt vanaf het bestand
omhoog op zoek naar een `.prettierrc`. Vindt hij niets, dan valt prettierd
terug op `PRETTIERD_DEFAULT_CONFIG` — hier `~/.config/prettier/.prettierrc`
(zshrc), dus in deze repo en mee in de backup. Daar staan `tabWidth: 4` en
`printWidth: 80`, en die gelden dus ook voor de codeblokken in je notities.

Omdat het een fallback is en geen override, wint een project met een eigen
`.prettierrc` gewoon. Wijzig je de globale config, dan moet de daemon zijn
omgeving opnieuw lezen: `prettierd restart`.

## Spelling

Staat uit. `spelllang` is `en` en dat spellingsbestand zit in de runtime,
dus `:setlocal spell` werkt meteen. Nederlands zit er niet bij; bij
`:setlocal spelllang=nl` biedt `spellfile.lua` uit de runtime aan het te
downloaden.

Tijdens het typen zijn de suggesties bereikbaar met `CTRL-X s`
(`:h ins-completion`), in normal mode met `z=`.
