# Shell-commando's: :! is kijken, :r ! is hebben

Drie manieren om een shell-commando vanuit nvim te draaien, oplopend in hoe
veel je met het resultaat wilt doen.

## :! — even kijken

`:!ls` toont de output onderin en klaar. Geen invoer mogelijk — `:!` loopt
via pipes, niet via een terminal; :h :! zegt zelf "Use :terminal to run an
interactive shell connected to a terminal". De output is ook geen buffer:
erin springen of yanken kan niet. Weggeschoten voor je het las: `g<` toont
hem nog eens in de pager (:h g< — "shows the last page of previous command
output"). Met ui2 is die pager wél een buffer: bewegen, zoeken en yanken
kan er, `q` sluit hem.

Staat het bericht nog op je scherm, dan springt `<Enter>` er meteen in —
zelfde pager, zelfde venster. `g<` is de variant voor achteraf.

## :r ! — output in een buffer

Wil je in de output bewegen, zoeken of kopiëren, dan moet ze een buffer in:

- `:r !cmd` — voert het commando uit en zet de output onder de cursor
  (:h :r! — "Execute {cmd} and insert its standard output below the cursor")
- `:0r !cmd` — bovenaan het bestand; elke regel als adres kan
- `:new | r !cmd` — in een lege scratch-split, je bestand blijft schoon;
  weggooien met `:bd!`
- zonder `!` bestaat het ook: `:r bestand` voegt een bestánd in

## :term — interactief

Vraagt het commando invoer, of loopt het lang: `:term cmd` (of een shell
ernaast met `:vs +term`, workflow.md). In de terminalbuffer kom je met
`CTRL-\ CTRL-N` in normal mode en beweeg/zoek/yank je gewoon door de
scrollback; `jk` doet hetzelfde (remap.lua).

## CTRL-F — de zwevende shell

Voor het snelle tussendoortje: `CTRL-F` schuift één shell over je code, `CTRL-F`
schuift hem weg (term.lua, werkt in beide modes). Wegschuiven is `nvim_win_hide`
en niet sluiten — het blijft dezelfde shell, met je halve commando, je
scrollback en je `cd` er nog in. Een `make` die loopt loopt door.

Ben je er met `CTRL-W w` uit gestapt zonder hem weg te schuiven, dan haalt
`CTRL-F` hem terug in focus in plaats van hem te sluiten. Sluit je hem per
ongeluk met `:q` of `CTRL-W o`, dan is alleen het venster weg: `CTRL-F` zet
dezelfde shell terug.

Hij volgt je ook naar een andere tab. Een float hoort bij één tabpagina, dus
`CTRL-F` haalt hem daar weg en zet hem hier neer — zelfde shell, geen tweede.

Eén shell, geen lijst met terminals: pas `exit` (of `CTRL-D`) ruimt echt op, en
de volgende `CTRL-F` start een verse. De buffer staat niet in `:ls` en niet in
`<leader>b`.

Blijvend werk hoort niet in die float maar in een split (`:vs +term`) of in een
tab; de float is bewust vluchtig.

Vuistregel: `:!` om even te kíjken; zodra je iets met de output wilt dóen,
hoort ze in een buffer (`:r !`) of een terminal.

Welk commando je erin typt om Java te draaien: runnen.md.
