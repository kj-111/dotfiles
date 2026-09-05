# Splits: twee bestanden naast elkaar

Sinds het kleinere font is er ruimte voor; `splitright`/`splitbelow` staan al
goed, nieuwe splits openen waar je ze verwacht.

## Openen

- `<leader>f` en dan `CTRL-V` — kies het bestand en open het meteen in een
  verticale split; `CTRL-S` doet het horizontaal, `CTRL-T` in een tab (pick.md)
- `CTRL-W v` — zelfde bestand twee keer: onder editen, boven een andere plek
  bekijken (het is één buffer, wijzigingen zie je in beide)
- `CTRL-W f` — open het bestand waarvan de naam onder de cursor staat in een split
- `:sp` — horizontale variant, opent onder
- `:vert h onderwerp` — help ernaast in plaats van erboven
- `:vs +term` — terminal naast je code; terug naar het bestand met `:b#`. Voor
  even iets tikken hoef je niet te splitsen: `CTRL-F` zweeft een shell erover
  (shell.md)

## Navigeren en opruimen

- `CTRL-W w` — wissel naar het volgende venster (bij twee splits genoeg)
- `CTRL-W p` — terug naar het vórige venster, ook met drie of meer splits
- `CTRL-W h/j/k/l` — gericht naar links/onder/boven/rechts
- `CTRL-W o` — alles dicht behalve dit venster; veilig, want de buffers
  blijven geladen — dé "focus op één"
- `CTRL-W T` — split naar een eigen tab; andersom kan ook: `:tab {cmd}`
  opent wat {cmd} zou splitsen meteen fullscreen in een tab —
  `:tab h onderwerp`, `:tab split` (:h :tab)
- `CTRL-W q` — dit venster dicht (venster vs buffer: zie buffers.md)

## Formaat

- `CTRL-W |` — huidig venster maximaal breed; `CTRL-W _` — maximaal hoog
  (de andere splits blijven bestaan, anders dan bij `CTRL-W o`)
- `CTRL-W =` — terug gelijk verdelen
- `CTRL-W <` / `>` — smaller/breder; `CTRL-W -` / `+` — lager/hoger
  (met teller: `10 CTRL-W >`)
- resizen is in de praktijk het handigst met de muis: sleep gewoon de
  scheidingslijn (`mouse = 'a'` staat aan)

## Verplaatsen

- `CTRL-W r` — wissel de splits van plek; `CTRL-W x` — wissel met de buurman
- `CTRL-W H/J/K/L` — duw dit venster helemaal naar links/onder/boven/rechts
  (handig om een `:sp` alsnog verticaal te leggen)

## Vergelijken

Twee bestanden naast elkaar diffen: in beide vensters `:diffthis`, klaar met
`:diffoff!`. Verschillen springen met `]c` / `[c`.

## Ontdekken

mini.clue: `CTRL-W` indrukken en 300 ms wachten toont alle window-commando's.
