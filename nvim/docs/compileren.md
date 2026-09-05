# Compileren: :make is Emacs' compile-mode

Emacs-gebruikers roemen `M-x compile`: commando draaien, fouten in een
buffer, next-error loopt ze af. Vim heeft dat model ingebouwd — quickfix
(:h 30.1):

- `M-x compile` → `:make`, springt zelf naar de eerste fout
- de compilation-buffer → de quickfixlijst (opent vanzelf, autocmds.lua)
- `next-error` → `]q` / `[q`
- `recompile` → `@:` (laatste `:`-commando), daarna volstaat `@@`
- `compilation-error-regexp-alist` → 'errorformat'

## Twee knoppen

`:make` draait 'makeprg' en leest de output met 'errorformat'. Hóe je
bouwt, en hoe je die output leest — los van elkaar in te stellen. In
makeprg is `%` het huidige bestand en `$*` waar `:make args` landt.

## :compiler is voorbereiding

`:compiler naam` draait niets; het vult die twee opties in, buffer-lokaal
(:h :compiler — "Without the ! options are set for the current buffer").
Onder water definieert het `CompilerSet` en doet
`:runtime! compiler/{naam}.{vim,lua}`.

```
VOOR   makeprg     = make (globaal)
       errorformat = generiek

NA     makeprg     = javac
       errorformat = %E%f:%l: error: %m,%W%f:%l: warning: %m,%-Z%p^,%-C%.%#,%-G%.%#
```

java.lua roept dat profiel aan en overschrijft daarna alléén makeprg:

```
makeprg     = javac -d out src/**/*.java     ← java.lua, jouw jinit-layout
errorformat = %E%f:%l: error: %m,...         ← javac-profiel, onaangeroerd
```

Het profiel weet hoe javac's fouten eruitzien, jouw config weet hoe jouw
project bouwt. Zelf een errorformat schrijven hoeft dus nooit.

Wat die codes doen: `%E` begint een fout, `%W` een waarschuwing, `%-C`
gooit vervolgregels weg, `%-G` de rest. `%-Z%p^` is de slimste — de `-`
houdt javac's caret-regel uit je lijst, maar `%p` telt de spaties ervoor
en berekent zo de kolom. Zonder profiel krijg je die caret als losse
rommelregel én geen kolom.

`:compiler <Tab>` toont de ruim honderd meegeleverde profielen,
`:compiler make` reset naar de default.

## Per taal

De profielen zijn allemaal meegeleverd; wie er één kiest verschilt. Voor
rust en python doet nvim's ftplugin dat, voor java niet — daar valt
maven/gradle/ant/javac niet te raden, dus kiest java.lua.

Die kijkt met `vim.fs.root()` omhoog vanaf de buffer, net als de
LSP-configs met hun root_markers. Zit de root in je cwd, dan blijft het
commando kort (`javac -d out src/**/*.java`); open je een bestand van
elders, dan worden de paden absoluut.

| taal   | keuze door | commando                                                                                              |
| ------ | ---------- | ----------------------------------------------------------------------------------------------------- |
| java   | java.lua   | pom.xml → maven; gradle-bestand → gradlew/gradle; `src/` → javac naar `out/`; los bestand → `javac %` |
| c      | c.lua      | Makefile → `make`; anders `make CFLAGS='-std=c23 -Wall -Wextra -g' %:r`                              |
| cpp    | c.lua      | idem met CXXFLAGS; cpp erft c.lua via `runtime! ftplugin/c`                                           |
| rust   | nvim zelf  | Cargo.toml naar bóven zoekend → cargo; anders rustc                                                   |
| python | beide      | testbestand → pytest daarop; andere code in een testproject → de hele suite                           |
| sh     | nvim zelf  | shellcheck, anders bash (`-n`) voor bash-bestanden                                                    |

De ftplugins checken `executable()`: pytest en shellcheck staan hier nog
niet, dus die regels vuren voorlopig niet.

Een Makefile lost dit voor java níet op. Make vergelijkt tijdstempels van
bron en doel, maar één `.java` levert onvoorspelbaar veel `.class` op —
inner classes, lambdas, anonieme klassen — en dat een constante in het ene
bestand het andere doet hercompileren staat er nergens in. Precies daarvoor
werd Ant gebouwd, en later Maven en Gradle. In C past make wél: één `.c`,
één `.o`.

Ook `:compiler javac` alleen volstaat niet: dat zet makeprg op kaal `javac`,
zonder bestanden en zonder `-d out`. `:make %` compileert dan één bestand
naast je bron. Het profiel levert de errorformat, java.lua het commando.

Linten zit hier bewust niet in. Ruff en jdtls draaien als LSP en melden
live (lsp.md); `:make` is de build, niet de stijl.

## Doelen uit je Makefile

Alles achter `make` is een doel (target) uit de Makefile, niet iets wat make
zelf kent. Staat er `run:` in, dan bestaat `make run`. En `VAR=waarde` op de
commandoregel zet een variabele voor die ene run.

De Makefile in `~/academia/projects/c/code` heeft er drie:

```
make              bouwt alles wat veranderd is
make hallo        bouwt één programma
make run F=hallo  bouwt het en draait het
make clean        ruimt de binaries op
```

`make <Tab>` vult de doelen niet aan, dus de Makefile openen is de manier om
te zien wat er is — bovenin staan ze in een comment.

## make[1] en "is up to date"

```
make[1]: `hallo' is up to date.
hallo, 42
```

Twee dingen tegelijk. "is up to date" betekent dat make niets gedaan heeft:
hij vergelijkt de tijdstempel van `hallo` met die van `hallo.c`, en de
binary was nieuwer. Dat is make's hele werkingsprincipe, en het is goed
nieuws — er viel niets te hercompileren. Raak je de bron aan, dan zie je in
plaats daarvan de `cc`-regel langskomen:

```
$ touch hallo.c && make run F=hallo
cc -std=c23 -Wall -Wextra -g -fsanitize=address,undefined -o hallo hallo.c
hallo, 42
```

Het getal in `make[1]` is het recursieniveau. Het `run`-doel roept make
opnieuw aan (`@$(MAKE) --no-print-directory $(F) && ./$(F)`), en die tweede
make noemt zich `make[1]`. Draai je het doel rechtstreeks, dan is er geen
recursie en staat er gewoon `make:`:

```
$ make hallo
make: `hallo' is up to date.
```

Dus: `[1]` betekent alleen "dit komt uit de sub-make", nooit dat er iets mis
is.

## Alle output gaat naar de pager

`:make`, `:!cmd` en elk ander commando dat meer print dan er past, komen in
nvim's pager terecht (`:h pager`). Zie je `(1 of 2)` of `page 1 of 2`, dan is
dat hem: er staat meer dan één scherm klaar.

De hint die nvim zelf toont is `f/d/j: screen/page/line down, b/u/k: up,
<Esc>: stop paging`. Voluit, uit `:h more-prompt`:

| toets                      | doet                    |
| -------------------------- | ----------------------- |
| `<Enter>` / `j` / `<Down>` | één regel verder        |
| `d`                        | een halve pagina omlaag |
| `<Space>` / `f` / `CTRL-F` | een heel scherm omlaag  |
| `G`                        | helemaal naar het einde |
| `k` / `<Up>` / `<BS>`      | één regel terug         |
| `u`                        | een halve pagina omhoog |
| `b` / `CTRL-B`             | een heel scherm terug   |
| `g`                        | terug naar het begin    |
| `q` / `<Esc>` / `CTRL-C`   | stoppen                 |

Merk op dat het de gewone bewegingsletters zijn, maar dan per scherm: `f`
forward, `b` back, `u` en `d` half. Dezelfde logica als `CTRL-F`/`CTRL-B` in
een buffer.

## De volle output achteraf: g<

Ben je de pager al voorbij, dan haalt `g<` hem terug (:h g< — "shows the
last page of previous command output"). Met ui2 is die pager een echte
buffer: bewegen, zoeken en yanken kan er, `q` sluit hem.

Staat het bericht nog op je scherm, dan doet `<Enter>` hetzelfde meteen. In
ui2 is het letterlijk dezelfde code; `g<` is de variant voor achteraf.

Dit is ook waarom de quickfixlijst en de pager los van elkaar staan: de
lijst houdt alleen wat 'errorformat' eruit vist, de pager heeft alles.

## En de LSP dan?

In Java heb je `:make` zelden nodig: jdtls toont dezelfde fouten al live en
compileert bij `:w` incrementeel naar out/ (lsp.md). Een lijst zonder build:
`:Pick diagnostic` (pick.md). `:make` wil je wél als:

- jdtls niet draait — dan is dit je foutenkanaal
- de build méér is dan compileren: Maven haalt dependencies, draait codegen
  en tests — dat ziet de LSP niet
- je zeker wilt weten dat het buiten de editor ook bouwt

Runnen doet `:make` niet. In Emacs is `M-x compile` óók de runner, maar
`:make` draait synchroon en heeft geen invoerkanaal. Dus: `:term` voor een
programma dat iets terugvraagt, `:!cmd` voor een korte run. De smaken staan
in shell.md, wat je dan typt in runnen.md.
