# Built-in autocomplete: 0.12 zet de motor erin

Aanvullen zat altijd al in vim, maar je moest het vragen: CTRL-N, of een
CTRL-X-mode. Nvim 0.12 voegt 'autocomplete' toe — hetzelfde mechanisme,
maar het menu komt vanzelf terwijl je typt (:h ins-autocompletion). Dat is
de eerste versie waarin de ingebouwde weg een plugin echt kan vervangen.

Jij draait blink.cmp; deze doc is het onderzoek naar wat eronder ligt en
wat je zou inleveren.

## Wat er zonder plugin al is

Veertien manieren, allemaal in insert mode (:h ins-completion):

```
CTRL-N / CTRL-P    woorden uit 'complete'      ← de gewone
CTRL-X CTRL-F      bestandsnamen               ← vaakst nuttig
CTRL-X CTRL-L      hele regels
CTRL-X CTRL-O      omni (= LSP, zie onder)
CTRL-X CTRL-]      tags
CTRL-X s           spellingsuggesties
CTRL-X CTRL-R      registerinhoud
```

Je hoeft ze niet te onthouden: mini.clue heeft `<C-x>` als trigger in
insert mode staan, met `gen_clues.builtin_completion()` erachter
(mini.lua). Druk CTRL-X en na 300 ms staat de lijst er.

In het menu accepteert CTRL-Y, CTRL-E annuleert, CTRL-L neemt één letter
over (:h popupmenu-keys). Enter accepteert alléén als je met de pijltjes
selecteerde — anders is het gewoon een regeleinde. Dat is de reden dat
half de wereld `inoremap <expr> <cr> pumvisible() ? '<c-y>' : '<cr>'` in
zijn config heeft staan; de help noemt die mapping zelf bij
:h complete_CTRL-Y.

## 'complete' is de bronnenlijst

Default `.,w,b,u,t`: huidige buffer, buffers in andere vensters, geladen
buffers, ontladen buffers, tags. Nieuw in 0.12 zijn de bronnen die géén
tekst scannen maar een functie aanroepen:

```
o        'omnifunc'      → bij een LSP-buffer is dat vim.lsp.omnifunc
F        'completefunc'
F{func}  een functie naar keuze (:h complete-functions)
f        buffernámen in plaats van bufferinhoud
kspell   het actieve woordenboek
```

Die `o` is het scharnier: daarmee zit LSP in dezelfde lijst als je
buffertekst, in één menu, zonder plugin.

## Wat 'autocomplete' oplost

Automatisch aanvullen breekt op één ding: een trage bron bevriest je
toetsaanslag. De oplossing is een aflopende tijdslimiet — bron 1 krijgt
'autocompletetimeout' ms (default 80), bron 2 de helft, enzovoort tot een
bodem. Alles draait, trage bronnen worden alleen snel weggezet.

Gemeten op een lua-bestand van 20.000 regels met 20.000 unieke
identifiers, `complete=.`, na het typen van "var" (snelste van 5):

```
CTRL-N, 'autocomplete' uit    20.000 matches   1227 ms
typen, 'autocomplete' aan      ~1.990 matches     86 ms
```

Dat is het hele verhaal in twee regels. Handmatig aanvullen mag traag
zijn — je vroeg erom en je wacht. Automatisch niet, en de limiet zorgt
dat je een deelantwoord krijgt in plaats van een hapering.

Wat níet werkte in 0.12.5: de per-bron limiet `.^5` uit de help
(":h 'complete'", "An optional match limit can be specified"). Nvim
accepteert de syntax en valideert hem (`cpt=.^` geeft E535), maar het
aantal matches bleef in alle proeven gelijk aan zonder limiet — ook met
twee bronnen (`.^2,w^2` op 6+6 woorden gaf gewoon 12). De tijdslimiet doet
het werk, de teller niet.

## 'completeopt' is wat je ziet

Zet 'autocomplete' aan en er wordt automatisch `noselect` bijgezet, want
niets is erger dan tekst die zichzelf invoegt terwijl je doortypt. Van de
rest heeft alleen `fuzzy`, `longest`, `popup`, `preinsert` en `preview`
nog effect (:h 'completeopt'). `preinsert` toont de rest van de eerste
kandidaat grijs achter je cursor, `popup` zet de documentatie in een
zwevend venster ernaast.

## LSP erbij: twee wegen

```
set autocomplete + set complete+=o
    nvim's motor, LSP als één bron naast buffer en tags, één menu

vim.lsp.completion.enable(true, id, buf, { autotrigger = true })
    LSP-gedreven, triggert op de triggerCharacters van de server
    (bij java is dat de punt), alléén LSP-items
```

De eerste bestaat pas sinds 0.12, de tweede al sinds 0.11. Ze bijten
elkaar niet.

Gemeten in jouw config, lua_ls op een lua-buffer:

```
typ "vim.fn.getcw" met:

  autocomplete + cpt='.,o'   → getcwd verschijnt vanzelf
  autocomplete + cpt='.'     → niets, staat niet in de buffer
  cpt='.,o' en dan CTRL-N    → niets
  CTRL-X CTRL-O              → getcwd
```

Die derde regel is de valkuil: omnifunc antwoordt asynchroon, en een
handmatige CTRL-N wacht daar niet op. De `o`-bron is er voor
'autocomplete', dat wél opnieuw kijkt als het antwoord binnenkomt.

Snippets en auto-imports werk je niet mis door `vim.lsp.completion.enable()`
over te slaan: CTRL-X CTRL-O registreert zelf de CompleteDone-haak — in
een proef zonder `enable()` stond de augroup `nvim.lsp.completion_1` er
meteen (runtime/lua/vim/lsp/completion.lua, `register_completedone`). Die
haak roept `vim.snippet.expand()` aan en past de textEdits toe.

Nog iets dat je niet hoeft in te stellen: nvim zet 'omnifunc' zelf op
`v:lua.vim.lsp.omnifunc` zodra een server aanhaakt — ook nu, met blink
ernaast. Het overschrijft alleen wat leeg is of uit $VIMRUNTIME komt, dus
de `omnifunc` die ftplugin/python.vim zet gaat er wel aan (lsp.lua,
`is_empty_or_default`).

## Wat blink erbovenop doet

- typotolerante fuzzy matching (frizbee, in rust) met frecency- en
  nabijheidsbonus; ingebouwd is er alleen `completeopt+=fuzzy`
- pad, snippets en buffer als eigen bronnen, plus de nvim-cmp-bronnen via
  een compatibiliteitslaag
- signature help (jij hebt die aan, blink.lua)
- 0,5–4 ms per toetsaanslag, async — tegenover een tijdslimiet die per
  definitie een deel van de bronnen afkapt

Wat je níet inlevert door over te stappen: LSP-items, snippets,
auto-imports, documentatiepopup, cmdline-aanvulling. Die zitten er
allemaal al in.

## Proberen zonder iets te slopen

Blink hoeft er niet uit; zet het per buffer aan en kijk hoe het voelt:

```vim
:setlocal autocomplete complete=.,o completeopt=menuone,noselect,popup
```

'autocomplete' is global-local, dus dit raakt alleen deze buffer
(:h 'autocomplete'). Bevalt het niet: `:setlocal noautocomplete`.

De cmdline heeft zijn eigen versie hiervan, met wildtrigger() in plaats
van 'autocomplete' — die staat al aan in autocmds.lua en is beschreven in
:h cmdline-autocompletion.

Bronnen: :h ins-autocompletion, :h 'complete', :h lsp-completion, en de
oorspronkelijke patch van Girish Palya —
https://github.com/vim/vim/pull/17812
