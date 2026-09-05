# Changelist: terug naar waar je wijzigde

Bij elke wijziging die je kunt undo'en onthoudt nvim de cursorpositie, per
buffer (:h changelist) — ook van wijzigingen die je daarna ongedaan maakte.
Dé situatie: je scrollt of springt weg om iets op te zoeken en denkt "waar
was ik aan het werken?" — `g;` brengt je terug.

- `g;` — naar de vorige wijzigplek; blijven drukken loopt verder terug
- `g,` — weer vooruit, richting de nieuwste
- een teller springt zo ver mogelijk: :h changelist zegt zelf "you can use
  999g; to go to the first change for which the position is still remembered"
- `:changes` — toon de lijst; `>` markeert waar je nu staat, de eerste kolom
  is de teller die je daarheen brengt
- `` `. `` — alleen de állerlaatste wijzigplek (marks.md); `gi` — spring naar
  de laatste insert-plek én typ daar verder

Kleine wijzigingen vlak bij elkaar op dezelfde regel tellen als één plek
("only the last one is remembered") — vijf keer `x` na elkaar vervuilt de
lijst dus niet.

Verschil met de jumplist (navigatie.md): de changelist is per buffer en
onthoudt alleen wijzigingen; de jumplist onthoudt élke sprong (zoeken, `G`,
`CTRL-]`, …) en wandelt met `CTRL-O`/`CTRL-I` ook over buffers heen. Zelfde
lengte, andere vraag: "waar wijzigde ik?" versus "waar wás ik?".
