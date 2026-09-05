# Marks: plekken een naam geven

- `ma` — zet mark a op de cursorplek; `` `a `` springt exact terug, `'a` naar
  het regelbegin
- kleine letters zijn per bestand; hoofdletters (`mA`, `` `A ``) zijn globaal
  óver bestanden heen en overleven een herstart (shada)
- `:marks` — overzicht; mini.clue toont ze ook al bij het intypen van `` ` ``
- `:delmarks a` — weg; `:delmarks!` — alle kleine letters in één keer

## Automatische marks (zetten zichzelf)

- `` `` `` — terug naar vóór je laatste sprong
- `` `. `` — naar je laatste wijziging (`g;` loopt de hele changelist af)
- `` `^ `` — naar de laatste insert-plek (`gi` springt erheen én typt verder)
- `` `0 `` — waar je zat toen je nvim de vorige keer afsloot (`` `1 `` de
  keer ervoor, enz.)

De laatste-positie-autocmd in autocmds.lua is hier ook op gebouwd: die doet
`` g`" `` — spring naar de plek waar het bestand de vorige keer verlaten werd.

Voor genummerde bestandsslots in plaats van letters: de arglist, met
`CTRL-1` … `CTRL-6` (navigatie.md).
