# Folds

Treesitter levert de foldstructuur ('foldexpr' in treesitter.lua): folds
volgen de code — klassen, methodes, blokken. (De LSP kan dit ook,
`vim.lsp.foldexpr()`, maar treesitter is hier de gekozen route.) Door
`foldlevel = 99` (set.lua) staat alles open bij het openen van een bestand;
folds zet je zelf.

- `za` — fold onder de cursor open/dicht (`zA` — recursief)
- `zM` — alles dichtklappen: het bestand als inhoudsopgave van methodes;
  `zR` — alles weer open
- `zj` / `zk` — naar de volgende/vorige fold
- `zv` — genoeg folds open om de cursorregel te tonen (de
  laatste-positie-autocmd doet dit bij de eerste lezing van een buffer)

## Twee soorten foldstatus

`zM` en `zR` verzetten 'foldlevel', een venster-optie, en die blijft staan als
je van bestand wisselt. Dat werkt alleen omdat 'foldlevelstart' uitstaat: die
zou 'foldlevel' bij elke nieuw gelezen buffer terugzetten, waardoor je `zM`
verdween zodra je één keer naar een ander bestand keek. Hij staat als comment
in set.lua; de default -1 laat het venster zijn eigen niveau houden.

Een `za`-fold is iets anders: losse status naast de buffer, die verdwijnt
zodra het bestand herlezen wordt, want dan berekent 'foldexpr' alles opnieuw.
Daar helpt binnen een sessie geen optie tegen — `:mkview` / `:loadview` zou het
bewaren, maar dat kost viewbestanden op schijf die verouderen.

Daarom slaat de `CTRL-1`…`CTRL-6`-mapping (config/arglist.lua) een sprong over naar het
bestand waar je al in zit: `:argument` is een `:edit` (:h :argument), dus dat
zou herlezen. De herlezing niet doen is goedkoper dan de folds terugzetten.

Over sessies heen is het wél geregeld: `folds` staat in 'sessionoptions', dus
morgen liggen je folds zoals je ze achterliet (sessie.md).
