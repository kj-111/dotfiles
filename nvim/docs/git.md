# Git: fugitive

Git zonder de editor te verlaten. Fugitive is geen eigen git-implementatie
maar een vertaallaag: `:Git {args}` draait gewoon het echte git-commando en
toont de output (:h :Git). Wat het toevoegt is dat de output een buffer is
— dus doorzoekbaar, met Enter erop springen, en met toetsen erop.

Volledige help: `:h fugitive`; in elke fugitive-buffer toont `g?` de
toetsen van dát venster (:h fugitive-maps).

## De statusbuffer

`:Git` zonder argumenten opent een samenvatting in de geest van
`git status` (:h fugitive-summary). Daar doe je het meeste werk:

- `s` — stage het bestand of de hunk onder de cursor; `u` — unstage;
  `-` — wisselen tussen die twee; `U` — alles unstagen
- `=` — klap de diff van dit bestand open in de lijst zelf
- `]c` / `[c` — naar de volgende/vorige hunk (zelfde grammatica als `]q`
  en `]d`, zie navigatie.md)
- `X` — gooi de wijziging onder de cursor weg (let op: onherroepelijk)
- `cc` — commit; `ca` — amend met bericht bewerken; `ce` — amend zonder;
  `cw` — alleen het bericht herschrijven
- `Enter` — open het bestand; `dv` / `ds` — open het in een verticale of
  horizontale diff-split

Werkt ook op een visuele selectie: meerdere bestanden of een deel van een
hunk in één keer stagen.

## Diffen en terugdraaien

- `:Gdiffsplit` — dit bestand naast de versie in de index; wijzigingen
  overzetten met de gewone diff-toetsen `do` en `dp` (:h copy-diffs)
- `:Gvdiffsplit` — hetzelfde, altijd verticaal
- `:Gread` — vervang de buffer door de versie uit git (een checkout die je
  met `u` ongedaan kunt maken, want het is een gewone buffer-wijziging)
- `:Gwrite` — schrijf op en stage in één keer

## Geschiedenis en zoeken

Beide landen in de quickfix, dus `]q` / `[q` lopen ze af (quickfix.md):

- `:Gclog` — de commit-historie als quickfixlijst; Enter opent die commit
- `:Gclog -- %` — alleen de historie van dít bestand
- `:Ggrep patroon` — git-grep over de repo
- `:Git blame` — wie schreef welke regel, in een scroll-gekoppelde split
  naast de code; `g?` toont daar wat je met een commit kunt doen

`:GBrowse` zit niet in deze opzet: Fugitive heeft daarvoor nog een aparte
hoster-provider nodig, en die laden we bewust niet.

## Gewone git-commando's

Alles wat git kan, kan hier: `:Git push`, `:Git log --oneline`,
`:Git switch -c tak`. Vraagt een commando om een editor (commit, interactive
rebase), dan opent dat in een split in dezelfde sessie in plaats van in een
tweede nvim.

Deze config-repo heeft twee remotes, dus pushen is `:Git push origin main`
én `:Git push gitlab main`.
