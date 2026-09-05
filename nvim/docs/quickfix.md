# Quickfix: compileren en fouten aflopen

Eén navigatiemodel voor compilerfouten, zoekresultaten en LSP-verwijzingen:
alles landt in de quickfix (of zijn kleine broer de location list), en de
lijst opent vanzelf (`QuickFixCmdPost` → `cwindow` in autocmds.lua).

## Bouwen met :make

Wat `:make` doet hangt af van de taal (after/ftplugin); het volledige
model — makeprg, errorformat, `:compiler` — staat in compileren.md:

- java — jinit-layout compileert `src/ → out/` met javac; Maven bouwt via de
  meegeleverde `:compiler maven`, Gradle via `./gradlew build`
- c — mét Makefile gewoon `make`; los bestand valt terug op de impliciete
  regel met `CFLAGS='-Wall -Wextra -g'`

Fouten staan daarna in de quickfix; Enter springt ernaartoe.

## Wat er nog meer in landt

- `:grep patroon` — zoeken met rg ('grepprg'), resultaat in de lijst
- `:Gclog` — de commit-historie; `:Ggrep` — git-grep over de repo (git.md)
- een picker: markeer met `CTRL-A` en open met `ALT-Enter` (pick.md)
- `grr` — alle verwijzingen naar het symbool onder de cursor
- `gO` — bestandsoutline, in de location list (sluiten met `:lclose`)
- `<leader>d` — alle huidige diagnostics rechtstreeks in de quickfix
- `:Pick diagnostic` — alle diagnostics die nvim nu kent; bij jdtls vaak ook
  uit ongeopende projectbestanden. Met `CTRL-A` en `ALT-Enter` gaan ze naar
  de quickfix (pick.md). De workflow na een brede wijziging staat in
  workflow.md

## Navigeren

- `]q` / `[q` — volgende/vorige item (ingebouwd sinds 0.11); `]Q` / `[Q` — laatste/eerste
- `:copen` / `:cclose` — lijst heropenen of dicht (of `CTRL-W q` in de lijst)
- location list: zelfde met l — `]l` / `[l`, `:lopen`, `:lclose`
- `:colder` / `:cnewer` — terug naar een vórige lijst (elke :make/:grep maakt een nieuwe)

## Op elke match iets doen

- `:cfdo %s/oud/nieuw/g | update` — zoek-en-vervang over alle bestanden in de
  lijst: eerst `:grep oud`, dan dit
- `:cdo` — zelfde, maar per match in plaats van per bestand
