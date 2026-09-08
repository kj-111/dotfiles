# Neovim 0.13: impact op deze config

> Onderzoekssnapshot van 4 september 2026. Neovim 0.13 is nog niet stabiel:
> de officiële releasechecklist staat open, bevat nog blockers en `news.txt`
> heeft nog lege onderdelen. Controleer dit document daarom opnieuw tegen
> `:help news` van de uiteindelijke `v0.13.0`.

## Kort besluit

Niet vooraf naar nightly overstappen. Wacht op de stabiele `v0.13.0`-tag. De
huidige configarchitectuur is al geschikt voor 0.13 en is met de officiële
nightly daadwerkelijk getest. Blink, Conform, Treesitter, mini.nvim, de
statusline, sessiecommando's, clangd en jdtls bleven werken.

Er is geen grote verbouwing nodig. Na de stabiele upgrade zijn zes gerichte
aanpassingen zinvol:

1. `vim.hl.on_yank()` vervangen door `vim.hl.hl_op()`;
2. de handgemaakte EOF-scroll-autocmd vervangen door `scrolloffpad=1`;
3. de oude keymap-optie `buffer` hernoemen naar `buf` (dit kan zelfs al op
   0.12.5);
4. `vim.opt.autoread = true` expliciet instellen;
5. het eigen sessiebeheer bewust laten samenwerken met de nieuwe `:restart`;
6. Neovims nieuwe `dir`-explorer expliciet uitschakelen ten gunste van
   MiniFiles.

De LSP-filewatcherbeperking voorlopig behouden. Het onderliggende
resourceprobleem is nog open en 0.13 laat ook `'autoread'` filewatchers
gebruiken.

## Wat daadwerkelijk getest is

De huidige config en huidige gepinde plugindata zijn gekopieerd naar een
geïsoleerde tijdelijke XDG-omgeving. Daarop draaide de officiële macOS arm64
nightly van 4 september 2026:

    NVIM v0.13.0-dev-1511+g5209695703

Resultaat:

| onderdeel                | resultaat                                                    |
| ------------------------ | ------------------------------------------------------------ |
| volledige config         | start zonder fout                                            |
| volledige `:checkhealth` | geen config- of pluginfout                                   |
| Blink                    | echt Insert-mode-menu, 103 LSP-items, item 1 geselecteerd    |
| Conform                  | Prettierd, Ruff en StyLua beschikbaar                        |
| clangd                   | initialiseert, completion werkt, juiste lokale Makefile-root |
| jdtls                    | initialiseert; na `Ready` werken completion en formatting    |
| statusline               | evalueert correct                                            |
| sessies                  | `:SessionCreate` en `:SessionDelete` bestaan                 |
| `vim.pack`               | lockfile wordt op de verwachte plaats gevonden               |
| realtime `'autoread'`    | externe wijziging verschijnt direct in de geladen buffer     |
| MiniFiles                | `nvim map/` en `:edit map/` openen MiniFiles                 |
| `:restart`               | eigen sessie wordt na Neovims herstel correct teruggevonden  |

De graphics-healthcheck faalde in de geïsoleerde headless testterminal. Dat
zegt alleen dat daar geen imageprotocol beschikbaar was; test `vim.ui.img`
interactief in Alacritty als je die functie ooit wilt gebruiken.

De tijdelijke testomgeving is na de controle volledig verwijderd. De
stabiele Neovim-installatie, plugindata en sessies zijn niet gewijzigd.

## Wijzigingen voor deze config

### 1. Yank-highlighting: doen na de upgrade

`vim.hl.on_yank()` is in 0.13 deprecated en staat gepland voor verwijdering in
0.14. De deprecation verschijnt pas wanneer `TextYankPost` werkelijk vuurt;
een gewone startupcontrole ziet hem dus niet.

Huidig in `lua/autocmds.lua`:

```lua
callback = function() vim.hl.on_yank({ higroup = 'YankHighlight' }) end,
```

Vanaf 0.13:

```lua
callback = function() vim.hl.hl_op({ higroup = 'YankHighlight' }) end,
```

Niet nu al onvoorwaardelijk veranderen: `vim.hl.hl_op()` bestaat nog niet in
0.12.5. Een versiecompatibele fallback kan, maar is voor de korte overgang
meer code dan nodig.

### 2. EOF-scrollen: vervangen door één optie

`set.lua` heeft `scrolloff=10`. `autocmds.lua` simuleert met een
`CursorMoved`/`CursorMovedI`-autocmd extra ruimte onderaan het bestand. 0.13
voegt daar precies de native optie `'scrolloffpad'` voor toe.

Na de upgrade:

```lua
vim.opt.scrolloff = 10
vim.opt.scrolloffpad = 1
```

Daarna kan de volledige autocmd met beschrijving `Keep scrolloff context near
the end of the file` weg. Elke waarde groter dan nul activeert de functie;
`1` is dus duidelijker dan de waarde van `scrolloff` dupliceren.

### 3. `buffer` naar `buf`: kleine API-opruiming

In de FileType-autocmd voor utilitybuffers staat:

```lua
vim.keymap.set('n', 'q', '<cmd>quit<CR>', {
  buffer = args.buf,
})
```

De huidige naam is `buf`. De oude naam blijft voorlopig werken, maar is al
deprecated. Dit mag op zowel 0.12.5 als 0.13:

```lua
vim.keymap.set('n', 'q', '<cmd>quit<CR>', {
  buf = args.buf,
})
```

### 4. Realtime autoread: expliciet aanzetten

`'autoread'` staat in 0.13 standaard aan, maar deze config mag de bewuste
keuze expliciet vastleggen:

```lua
vim.opt.autoread = true
```

In 0.13 gebruikt `'autoread'` gedeeltelijk OS-filewatchers. Daardoor worden
externe bestandswijzigingen onmiddellijk gedetecteerd, in plaats van pas bij
bijvoorbeeld `FocusGained` of `:checktime`. De expliciete instelling verandert
de standaard dus niet, maar voorkomt onduidelijkheid over het gewenste gedrag.

### 5. Sessies: rekening houden met `:restart`

`:restart` maakt in 0.13 zelf een tijdelijke sessie, start een nieuw
Neovim-proces en herstelt die toestand na `VimEnter`. De huidige
`VimEnter`-autocmd kan intussen ook de opgeslagen projectsessie voor de cwd
herstellen. Dat kan dezelfde sessie dubbel laden en, belangrijker, onbedoeld
een oude projectsessie activeren wanneer de oorspronkelijke Neovim helemaal
geen actieve projectsessie had.

Na de upgrade moet `fresh_start()` daarom alleen automatisch een projectsessie
herstellen bij een normale start:

```lua
if vim.v.startreason ~= 'normal' then return false end
```

Alleen deze guard toevoegen is niet voldoende. Na een gewone `:restart` moet
`session_path` na Neovims eigen restore opnieuw worden afgeleid van
`vim.v.this_session`, zodat de actieve projectsessie bij later afsluiten blijft
opslaan. Doe dat in een geplande callback na `UIEnter`; bij `:restart!` blijft
`session_path` bewust leeg. Implementeer en test dit pas tegen de stabiele
release, omdat `:restart` en zijn UI-lifecycle nog nieuw zijn.

### 6. Ingebouwde `dir`-explorer expliciet uitschakelen

Neovim 0.13 laadt standaard zijn nieuwe `dir`-plugin voor directorybuffers.
MiniFiles blijft hier bewust de standaard explorer. Zet daarom vóór het laden
van de plugins in `lua/set.lua`:

```lua
vim.g.loaded_nvim_dir_plugin = 1
```

Zonder die vlag opent MiniFiles in de geteste nightly uiteindelijk nog steeds
zowel `nvim map/` als `:edit map/`, maar Neovims twee `nvim.dir`-autocmds zijn
dan eerst ook actief. De officiële disable-vlag voorkomt die dubbele
afhandeling volledig. Dit is getest met dezelfde config op zowel 0.12.5 als
0.13-nightly en verstoort MiniFiles op geen van beide versies.

### Wat niet moet veranderen

- `vim.lsp.config('*', ...)` en `vim.lsp.enable()` zijn nog steeds de juiste
  native LSP-architectuur.
- De aparte `nvim-jdtls.start_or_attach()` blijft nodig voor zijn persistente
  Java-workspace en projectinstellingen.
- Blink hoeft niet vervangen te worden door native completion. De nieuwe
  native LSP-completionfuncties zijn goed, maar Blink levert nog steeds de
  gekozen UI, fuzzy matching, bronnen, snippets en `super-tab`-gedrag.
- Conform met `lsp_format = 'fallback'` blijft correct.
- De statusline gebruikt `%=` buiten itemgroepen en wordt niet geraakt door de
  gewijzigde truncatieregels.
- De huidige `nvim-pack-lock.json` staat al exact op de nieuwe standaardlocatie
  en hoort in Git te blijven.
- MiniFiles blijft de juiste keuze voor de gekozen explorerworkflow. Gebruik
  daarbij wel de expliciete `loaded_nvim_dir_plugin`-vlag hierboven.

## API-audit van de huidige Lua-config

Alle eigen `vim.*`- en `nvim_*`-calls zijn vergeleken met de officiële 0.13-
deprecations en breaking changes. Er zijn maar twee echte herschrijvingen:

| huidig gebruik                           | status                                 | actie                                      |
| ---------------------------------------- | -------------------------------------- | ------------------------------------------ |
| `vim.hl.on_yank()`                       | deprecated in 0.13                     | na upgrade naar `vim.hl.hl_op()`           |
| keymapoptie `{ buffer = args.buf }`      | deprecated sinds 0.12                  | naar `{ buf = args.buf }`; kan nu al       |
| `nvim_win_get_height()`                  | publiek en geldig                      | behouden                                   |
| `nvim_win_get_config()`/`set_config()`   | publiek en geldig                      | behouden                                   |
| `nvim_win_set_height()`/`set_width()`    | deprecated in 0.13, maar nergens benut | niets doen                                 |
| `nvim_create_autocmd()` en `args.buf`    | publiek en geldig                      | behouden; eventveld `args.buf` is niet oud |
| `vim.lsp.config()` en `vim.lsp.enable()` | actuele publieke LSP-API               | behouden                                   |
| overige gebruikte `vim.lsp.*`-functies   | geen 0.13-deprecation gevonden         | behouden                                   |
| `vim.treesitter.start()` en `foldexpr()` | actuele publieke API                   | behouden                                   |
| `vim.fs.root/joinpath/dir/rm`            | actuele publieke API                   | behouden                                   |
| `vim.uv.fs_stat()`                       | actuele libuv-naam                     | behouden                                   |
| `vim.fn.jobstart(..., { term = true })`  | vervanging voor deprecated `termopen`  | behouden                                   |
| `require('vim._core.ui2')`               | interne, onstabiele API                | `pcall` behouden en na release hertesten   |

De 0.13-hernoeming van `buffer` naar `buf` bij verschillende autocmd-API's
betekent niet dat callbackdata zoals `args.buf` verandert. In deze config komt
de oude autocmdoptie niet voor; alleen de keymapoptie moet worden aangepast.

### Alleen optionele modernisering

Na 0.13 kunnen de twee aanroepen van:

```lua
vim.fn.mkdir(session_dir, 'p')
```

worden vervangen door de nieuwe native Lua-API:

```lua
vim.fs.mkdir(session_dir, { parents = true })
```

Dat is netter, maar geen bugfix en geen vereiste voor 0.13. Ook stringvormen
zoals `vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'` en de huidige
`vim.cmd`-aanroepen blijven ondersteund. Ze uitsluitend voor stijl herschrijven
zou meer diff dan functionele winst geven.

## Nieuwe functies die hier echt nuttig zijn

### Native multicursor

0.13 voegt multicursors aan de editor zelf toe:

- `Q` plaatst of verwijdert een cursor;
- `[count]Q` plaatst cursors op zoekresultaten;
- `q=` wisselt follow-mode;
- `CTRL-L` wist de cursors en `gQ` herstelt ze.

Deze config heeft geen eigen `Q`-mapping, dus er is geen conflict. Let wel: `Q`
herhaalt in 0.13 niet langer het laatst opgenomen register en `gQ` opent niet
langer de oude Ex-mode.

### Native pluginbeheer wordt bruikbaarder

De bestaande `vim.pack.add()`-setup blijft geldig. Nieuw zijn:

- `:packupdate` — updates ophalen, diff bekijken en met `:write` bevestigen;
- `:packupdate ++offline` — alleen de huidige toestand bekijken;
- `:packupdate ++lockfile` — de revisions uit de lockfile herstellen;
- `:packdel` — inactieve plugins van disk verwijderen;
- `'packlockfile'` — configureerbare locatie van de lockfile;
- `pkg.json`-manifests — plugins kunnen lifecyclehooks en metadata leveren.

Voor deze config is de standaardwaarde van `'packlockfile'` al:
`$XDG_CONFIG_HOME/nvim/nvim-pack-lock.json`. Zet de optie dus niet expliciet.
Na 0.13 kan de comment in `config/plugins.lua` wel `:packupdate` noemen in
plaats van alleen `vim.pack.update()`.

### Betere LSP-fundamenten

0.13 brengt onder meer:

- nested snippets;
- native ondersteuning voor completion-`preselect` en commit characters;
- correctere toepassing van `CompletionList.itemDefaults`;
- definitie/declaration/implementation/type-definition volgt `'switchbuf'`;
- die navigatiefuncties accepteren een willekeurige positie;
- `vim.lsp.formatexpr()` valt voor een hele buffer terug op
  `textDocument/formatting` wanneer range-formatting ontbreekt;
- een LSP-hoverfloat die je met bijvoorbeeld `CTRL-W H` in een normaal window
  omzet, wordt niet langer automatisch gesloten;
- minder allocaties bij interne LSP-data en minder semantische-tokenflicker.

De meeste completionverbeteringen zijn voor Neovims eigen completionclient.
Blink adverteert zijn eigen capabilities en blijft verantwoordelijk voor de
zichtbare completionworkflow. De nightly-test bevestigde dat die combinatie
werkt.

Een proces met `cmd = { ... }` start voortaan standaard met de LSP-root als
werkdirectory. Dat is gunstig voor clangd, BasedPyright, Ruff, vtsls en jdtls.
Deze config gebruikt absolute instellingen waar nodig en veronderstelt nergens
de oude Neovim-cwd, dus er is geen migratie nodig.

### Treesitter

- highlighting van grote bestanden met veel injections wordt volgens de
  officiële notes 50–100% sneller;
- `vim.treesitter.select()` kan een syntaxnode selecteren of uitbreiden;
- `]N` en `[N` breiden een visuele selectie uit naar siblingnodes;
- de `diff`-parser wordt meegeleverd;
- `@noconceal` kan conceal per capture voorkomen.

De huidige Treesitter-setup gebruikt al de nieuwe plugin-API en bevat de
vereiste `vimdoc`-parser. Dat laatste is belangrijk, omdat `:helptags` in 0.13
de vimdoc-parser gebruikt.

### Editor en workflow

- `'scrolloffpad'`: vervangt onze EOF-scroll-autocmd.
- `:restart`: bewaart en herstelt nu zelf de tijdelijke editorstaat;
  `:restart!` doet dat niet. Dit vervangt de duurzame projectsessies niet, maar
  vereist wel de sessie-aanpassing hierboven.
- `ZR` voert `:restart` uit. Dit is hoofdletter `Z`, niet het foldcommando
  `zR`.
- `:bcd` geeft een buffer een eigen cwd. De sessiecode gebruikt bewust de
  globale cwd via `getcwd(-1, -1)` en blijft daardoor stabiel.
- `:detach!` laat Neovim doordraaien als de TUI onverwacht verdwijnt;
  `:connect` kan later opnieuw verbinden.
- `:log` opent logbestanden en `:uptime` toont de draaitijd.
- `al` en `il` zijn textobjects voor de hele buffer en de inhoud van de
  huidige regel.
- `gf` begrijpt nu `file://`-URI's.
- undo herstelt de cursor nauwkeuriger naar zijn positie vóór de wijziging.

### Bestaande pickers krijgen MiniPick

De ingebouwde menu's van `:browse oldfiles`, `:recover`, `:tselect` en `z=`
roepen in 0.13 `vim.ui.select()` aan. `mini.pick.setup()` vervangt die functie
al door `MiniPick.ui_select`. Deze commando's krijgen daardoor zonder extra
config automatisch dezelfde MiniPick-interface.

### Nieuwe directorybrowser

0.13 laadt standaard een kleine ingebouwde `dir`-browser wanneer een
directorypad wordt geopend. De browser:

- toont een directory als een read-only buffer en wijzigt zelf geen bestanden;
- opent een item met `<CR>`, gaat omhoog met `-` en herlaadt met `R`;
- gebruikt een bufferlokale cwd via `:bcd` en bewaart het alternate file voor
  `CTRL-^`;
- ondersteunt sorteren of filteren via `DirReadPost`;
- kan bestandstypes, executables en symlinkdoelen decoreren;
- vormt ook de interface van de nieuwe read-only zipbrowser.

Dat is een goede native, minimalistische vervanger voor netrw. MiniFiles blijft
voor deze config echter beter passen door zijn kolommen, previews en
bestandsbewerkingen met trash-ondersteuning. Schakel `dir` daarom expliciet uit
zoals bij wijziging 6 beschreven; zo is er precies één eigenaar van
directorybuffers.

### Lua- en filesystem-API

Interessant voor toekomstige vereenvoudiging, maar nu niet nodig:

- `vim.async` voor gestructureerde async taken en cancellation;
- `vim.fs.mkdir(path, { parents = true })` als Lua-alternatief voor
  `vim.fn.mkdir(path, 'p')`;
- `vim.fs.slug()` voor veilige, leesbare bestandsnamen met collisionhash;
- `vim.fs.dir(..., { err = true })` en foutresultaten van `vim.fs.find()`;
- `vim.log` als centrale logging-API;
- Lua-functies direct in opties zoals `foldexpr` en `indentexpr`;
- `vim.ui.img` voor afbeeldingen in ondersteunde terminals/UI's.

De sessienamen nu naar `vim.fs.slug()` omzetten zou bestaande sessiebestanden
een andere naam geven. Dat is geen verbetering waard. Ook de huidige
Treesitter-expressies blijven geldig; een functionele rewrite is optioneel en
hoeft niet bij de upgrade.

## Nieuwe opties en optiegedrag

| optie/wijziging            | betekenis                                 | advies hier                                                      |
| -------------------------- | ----------------------------------------- | ---------------------------------------------------------------- |
| `'scrolloffpad'`           | laat `scrolloff` ook aan EOF doorlopen    | na upgrade op `1`; autocmd weg                                   |
| `'packlockfile'`           | pad van de `vim.pack`-lockfile            | default behouden                                                 |
| `'winpinned'`              | voorkomt impliciet sluiten van een window | alleen gebruiken als een concrete windowworkflow het nodig heeft |
| `'previewpopup'`           | toont previewwindows als float            | optioneel; LSP-hover en mini-preview dekken dit al               |
| `'messagesopt'` `pager:`   | kiest de toets die ui2's pager opent      | default `g<` proberen; eventueel `pager:<CR>` toevoegen          |
| `'messagesopt'` `timeout:` | levensduur van ui2-berichten              | alleen instellen als de default hinderlijk blijkt                |
| tab-local `'cmdheight'`    | andere cmdlinehoogte per tab              | niet nodig voor de huidige globale layout                        |
| `'shortmess'` `u`          | verbergt undo/redo-meldingen              | smaakkeuze, geen noodzakelijke optimalisatie                     |

`vim.o`, `vim.opt` en `nvim_set_option_value()` expanderen vanaf 0.13 `~` en
environmentvariabelen in optiewaarden. De huidige config zet geen risicovolle
letterlijke paden in opties, dus dit breekt niets.

Lua-functies kunnen rechtstreeks aan `foldexpr`, `indentexpr`, `formatexpr` en
andere functie-/expressieopties worden toegewezen. Zulke functies kunnen niet
door `:mksession` worden geserialiseerd. Deze config bewaart bewust geen
`options` in `'sessionoptions'`, dus ook dat vormt hier geen probleem.

De overige 0.13-API-breuken zijn eveneens gecontroleerd: deze config
inspecteert geen RPC-callbackfuncties, gebruikt geen lege autocmdevents of
-patterns, hangt niet af van de experimentele returnvorm van `vim.opt:get()`,
gebruikt `vim.pos`/`vim.range` niet en roept `nvim_exec_autocmds()` niet met een
buffercontext aan. Daaruit volgt geen extra rewrite.

## Filewatchers: voorlopig voorzichtig blijven

0.13 gebruikt OS-filewatchers voor `'autoread'`, zodat externe wijzigingen
realtime zichtbaar worden. Dat is nuttig, maar Neovims watcherlaag heeft nog
een open issue rond `EMFILE`/uitgeputte handles, vooral op macOS en bij grote
LSP-workspaces.

Daarom:

- `workspace/didChangeWatchedFiles.dynamicRegistration = false` behouden;
- `vim.opt.autoread = true` expliciet instellen na de upgrade; deze
  buffergerichte watchers zijn veel beperkter dan recursieve
  LSP-workspacewatchers;
- na de upgrade `:checkhealth` bekijken, sectie Performance/filewatchers;
- bij een nieuwe `EMFILE` eerst het actuele upstreamissue controleren en pas
  daarna beslissen over een tijdelijke `'noautoread'`-fallback.

Open buffers blijven via LSP normaal synchroniseren. Externe project- of
buildwijzigingen vragen met de bestaande beperking soms `:lsp restart` of bij
Java `:JdtUpdateConfig`.

## Brekende wijzigingen: controle tegen deze config

| 0.13-wijziging                                         | gebruik hier                                | gevolg                                |
| ------------------------------------------------------ | ------------------------------------------- | ------------------------------------- |
| `Q` is multicursor; `gQ` geen Ex-mode                  | niet gemapt                                 | nieuw gedrag leren, geen configbreuk  |
| Insert-`.` herhaalt ook cursorbewegingen               | geen pijltjestoetsmappings                  | nieuw standaardgedrag                 |
| Visual-`.` herhaalt semantisch                         | geen eigen repeat-config                    | nieuw standaardgedrag                 |
| statusline-itemgroepen/truncatie gewijzigd             | `%=` staat buiten groepen                   | geen wijziging                        |
| LSP-process-cwd wordt `root_dir`                       | Rust zet cwd expliciet                      | Rust-cmd kan na upgrade eenvoudiger   |
| `client.attached_buffers[buf]` bevat languageId        | eigen code gebruikt `vim.lsp.get_clients()` | geen wijziging                        |
| LSP `reuse_win` verwijderd                             | nergens gebruikt                            | geen wijziging                        |
| `BufModifiedSet` verwijderd                            | nergens gebruikt                            | geen wijziging                        |
| `vim.opt`-operatoren niet ketenen                      | nergens geketend                            | geen wijziging                        |
| `stdpath('log')` verhuist naar `stdpath('state')/logs` | geen hardcoded logpad                       | alleen pad in health-output verandert |
| lege autocmdpatterns niet meer als nil                 | nergens gebruikt                            | geen wijziging                        |
| `vim.fs.normalize(..., expand_env=false)` hernoemd     | arglist gebruikt dit voor letterlijke paden | na upgrade `plain=true` gebruiken     |
| `:helptags` vereist vimdoc-parser                      | parser staat in de lijst                    | reeds in orde                         |
| `vim.hl.on_yank()` deprecated                          | één autocmd                                 | vervangen na upgrade                  |
| keymapoptie `buffer` deprecated                        | één mapping                                 | hernoemen naar `buf`                  |

## ui2 blijft het meest experimentele onderdeel

Deze config activeert ui2 via:

```lua
pcall(function() require('vim._core.ui2').enable({}) end)
```

Dat blijft op de geteste nightly werken. De underscore in `vim._core` betekent
wel dat dit geen stabiele publieke API is. 0.13 verplaatst ui2-instellingen
zoals pager-toets en berichttimeout naar `'messagesopt'`; de config gaf die
oude velden niet mee en breekt dus niet.

Standaard opent `g<` de volledige berichtpager. Als `<CR>` prettiger is, kan
na de upgrade expliciet:

```lua
vim.opt.messagesopt:append('pager:<CR>')
```

Maak die keuze op gedrag, niet preventief. Als ui2 tegen de uiteindelijke
0.13-release toch verandert, zorgt de `pcall` ervoor dat de rest van de config
blijft starten, maar dan val je terug op de klassieke message-UI.

## Veilige upgradevolgorde

1. Wacht tot `nvim --version` werkelijk `NVIM v0.13.0` zonder `-dev` meldt.
2. Zorg voor een schone Git-status en maak de normale `.config`-backup.
3. Upgrade alleen Neovim; laat de huidige plugin-lockfile eerst ongemoeid.
4. Start en controleer:

       :checkhealth
       :checkhealth vim.deprecated
       :checkhealth vim.lsp
       :checkhealth conform

5. Test minstens Blink, C/clangd, Python/BasedPyright+Ruff en Java/jdtls zoals
   bij deze audit.
6. Voer daarna de zes gerichte aanpassingen bovenaan uit en test opnieuw.
7. Test een actieve projectsessie met `:restart` en controleer `nvim .`.
8. Update plugins pas in een aparte stap met `:packupdate`; review en commit de
   lockfile afzonderlijk. Zo is bij een fout duidelijk of core of een
   pluginupdate de oorzaak is.

## Bronnen

- [Officiële 0.13-ontwikkelnotes (`:help news`)](https://neovim.io/doc/user/news/)
- [Officiële releasechecklist en nog open blockers](https://github.com/neovim/neovim/issues/41449)
- [Officiële nightly releases](https://github.com/neovim/neovim/releases/tag/nightly)
- [Officiële deprecated API-lijst](https://github.com/neovim/neovim/blob/master/runtime/doc/deprecated.txt)
- [Officiële opties](https://neovim.io/doc/user/options/)
- [Officiële `vim.pack`-documentatie](https://github.com/neovim/neovim/blob/master/runtime/doc/pack.txt)
- [Officiële ingebouwde plugins, waaronder `dir`](https://neovim.io/doc/user/plugins/)
- [Officiële documentatie van `:restart`](https://neovim.io/doc/user/gui/#:restart)
- [Open filewatcher/`EMFILE`-issue](https://github.com/neovim/neovim/issues/40238)

Laatste hercontrole: zodra de stabiele tag verschijnt, omdat de huidige
`news.txt` expliciet nog ontwikkelonderdelen en `todo`-secties bevat.
