# Workflows: alles samen

De losse onderdelen staan in de andere docs; hier de vaste routines die ze
combineren.

## Starten: alles klaarzetten

De cwd is het anker: de pickers, `:grep`, `:make` en de LSP-root werken
allemaal vanaf daar — én de sessie, zie onderaan.

1. In de terminal `cd` naar de projectmap, dan `nvim` zonder argumenten: zo
   wordt de projectsessie hersteld en later weer bewaard. `nvim .` (start in
   mini.files) of `nvim src/Main.java` is bewust een eenmalige start zonder
   automatisch sessieherstel of -bewaring
2. Nieuw Java-project: eerst `jinit naam`; losse map zonder projectbestanden:
   `touch .java-root`, anders vindt jdtls zijn root niet
3. Werkset opbouwen: bestanden zoeken met `<leader>f`, vastzetten
   met `<leader>h` en dan `a` — daarna schakelt CTRL-1…6 (navigatie.md); eenmaal
   alles open is `:b naam` de kortste sprong (buffers.md)
4. Bestanden bekijken of beheren: `<leader>e` — mini.files (files.md)
5. Terminal ernaast voor het runnen: `:vs +term` (de Java-loop hieronder)
6. Toch verkeerd gestart: `:cd map` verlegt het anker binnen de sessie
   (`:pwd` toont waar je zit). Ook handig als je werk zich naar een submap
   verplaatst — dan worden relatieve commando's als `:e bestand` weer kort.
   Alleen voor dít venster: `:lcd map` — ":h :lcd: only set the current
   directory for the current window"; andere splits houden het anker
7. Klaar: `:qa` — na de argumentloze projectstart wordt de sessie bewaard,
   zie onderaan

## Twee bestanden naast elkaar

1. In de terminal `cd` naar de projectmap, dan `nvim`
2. `<leader>f` — het eerste bestand
3. `<leader>f` opnieuw, en dit keer `CTRL-V` in plaats van Enter: het tweede
   bestand opent meteen in een verticale split
4. Breedte bijstellen: sleep de scheidingslijn met de muis (`mouse = 'a'`
   staat aan); weer gelijk verdelen met `CTRL-W =`
5. Wisselen: `CTRL-W w`; dicht: `CTRL-W q` — de rest: splits.md

## Folds als abstractielaag

Folds dienen ook als visuele werklijst. Bij TDD is een methode pas klaar nadat
ze geïmplementeerd is en de bijbehorende tests groen zijn. Klap ze daarna met
`za` dicht: de afgewerkte implementatie wordt een abstract detail, terwijl de
nog open code toont waar er verder gewerkt moet worden.

Dit vervangt de tests niet — hun groene resultaat bewijst dat de methode klaar
is; de fold bewaart alleen het overzicht. Met `zM` zie je het bestand als een
inhoudsopgave van methodes, en met `zR` open je alles opnieuw. De overige
foldcommando's staan in folds.md.

## Java: bewerken → compileren → runnen

Jinit-project (src/ → out/), je zit in een .java-bestand.

1. Bewerken en `:w` — jdtls formatteert én compileert incrementeel naar
   `out/` (zie lsp.md); fouten zie je meteen als diagnostics (`]d`)
2. Runnen: `CTRL-F` voor de zwevende shell, dan `java -cp out Main` — jdtls
   heeft bij `:w` al gecompileerd, dus bouwen hoeft niet (runnen.md; bij een
   maven-project is het `target/classes`). Output naast je code houden:
   `:vs +term` (de smaken staan in shell.md)
3. Terug naar de code: nog eens `CTRL-F`, of `CTRL-W h` bij een split
4. Iets aangepast? `:w`, terug naar de shell, en het vorige commando met
   `CTRL-P` + Enter — de zsh-historie is gedeeld over alle shells
   (SHARE_HISTORY in zshrc), dus ook een vérse terminal kent je commando's
5. Liever de compilerfouten in een lijst dan als diagnostics: `:make` en
   `]q` (zie quickfix.md)

## Compileren → fouten aflopen

Werkt in elke taal hetzelfde; wat `:make` precies draait en waarom
(makeprg, errorformat, `:compiler`, de Emacs-parallel): compileren.md.

1. `:make` — bouwt, springt naar de eerste fout; de quickfixlijst opent vanzelf
2. `]q` / `[q` — de fouten aflopen (Enter in de lijst springt ook)
3. Fixen, `:w`, en opnieuw bouwen met `@:` (laatste commando herhalen - daarna volstaat `@@`)

Wat je nog meer met die lijst kunt — `:colder`, `:cdo`, de location list:
quickfix.md.

## Eén wijziging, fouten door de hele codebase

Je verandert iets waar overal naar verwezen wordt — een signatuur, een
type, een methode erbij in een interface — en dat breekt bestanden die je
niet openhebt. Ze allemaal langs gaan hoeft niet: jdtls compileert het hele
project en publiceert diagnostics voor élk bestand, ook voor buffers die
nooit geopend zijn. Die haal je in één keer op.

Eerst de uitzondering: gaat het puur om hernoemen, gebruik dan `grn`. Die
doet naam, bestandsnaam en alle verwijzingen in één keer, en dan is er
niets te fixen (lsp-keys.md). De rest hieronder is voor wat `grn` niet dekt.

1. Doe de wijziging en `:w` — jdtls hercompileert en de fouten verschijnen
2. Even wachten tot hij klaar is; bij een groot project duurt de herbouw
   een paar seconden
3. `:Pick diagnostic sort_by='severity'` — alle diagnostics van het project,
   fouten bovenaan. Typen filtert; zo hou je bijvoorbeeld één bestand over
4. Wil je ze stuk voor stuk aflopen: Enter op de eerste en fixen. Wil je een
   werklijst: `CTRL-A` markeert alle huidige treffers, `ALT-Enter` zet ze in
   de quickfix, en dan lopen `]q` / `[q` erdoorheen (pick.md)
5. Na het fixen opnieuw ophalen: zowel de picker als de quickfix zijn
   momentopnames, geen live venster
6. Fouten weg? Dan verschijnen de waarschuwingen pas: zolang een bestand een
   compileerfout heeft, houdt jdtls de waarschuwingen erin achterwege.
   Nog een ronde door de picker vindt dus de ongebruikte imports en dode
   variabelen

Gaat de fix overal hetzelfde: `:cdo s/oud/nieuw/e | update` doet hem op elke
match in de lijst, `:cfdo` per bestand (quickfix.md).

Wanneer liever `:make`: als jdtls uit staat, of als je de compiler zelf het
laatste woord wilt geven. Die draait bij een jinit-project
`javac -d out src/**/*.java` — dus ook over álles, alleen dan als build in
plaats van als live diagnose. Wanneer je wat wil: compileren.md.

## Terugkomen: de sessie

Sluit je nvim af, dan wordt de stand van die map bewaard: je buffers, de
arglist, de vensterindeling, je folds en zelfs de terminal-split (die komt
terug met een verse shell). Start je later `nvim` zónder argumenten in
dezelfde map, dan staat alles er weer.

- de sessie hangt aan de cwd, dus `~/project` en `~/project/src` zijn er twee
- `nvim bestand.java` overslaat het herstel: met een argument wil je dát
  bestand, niet je vorige stand; zo'n eenmalige start overschrijft de bewaarde
  projectsessie bij afsluiten ook niet

Hoe het werkt, waar het staat en wat er precies in gaat: sessie.md.
