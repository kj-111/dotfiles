# Oil: de verkenner als gewone buffer

Volledige help: `:h oil`; in de verkenner toont `g?` alle toetsen.

| toets | doet |
|---|---|
| `<leader>e` | openen op het huidige bestand, nog eens = sluiten |
| `l` | de map in, of het bestand openen |
| `h` of `-` | een niveau terug |
| `_` | naar de cwd |
| `` ` `` | zet nvims cwd naar de map waar je nú staat |
| `<C-s>` / `<C-t>` | het bestand openen in een verticale split of een tab |
| `<C-p>` | preview van het bestand onder de cursor |
| `<C-o>` | terug waar je vandaan navigeerde (Vim zelf, zie onder) |
| `gx` | het bestand openen in de app die macOS ervoor kent |
| `gs` | sorteervolgorde wijzigen |
| `<C-l>` | de lijst opnieuw inlezen |
| `g.` | dotfiles aan/uit; `g\` — de prullenbak |

Open je oil vanuit een bestand, dan staat de cursor meteen op dat bestand in
de lijst. En andersom brengt sluiten je terug naar precies waar je was.

`<C-o>` is geen oil-toets. Het staat niet in zijn keymaps en er is geen
`actions.back` — het is de gewone jumplist van Vim (`:h jump-motions`), en die
werkt hier omdat een oil-map een echte buffer is. Elke stap door de boom is
dus een gewone buffersprong, met `<C-i>` weer vooruit. Precies dat maakt oil
anders dan een zwevende verkenner: je hoeft geen tweede navigatiegeschiedenis
te leren.

Wat er níét is: een actie die rechtstreeks naar de map van je geopende bestand
springt. `_` komt in de buurt maar gaat naar nvims cwd, wat iets anders is.

Oil verving mini.files, dat de hele tak naast elkaar toonde in zwevende
kolommen. Oil toont één map als een buffer in je huidige venster. Die buffer
is echt genoeg om mee te werken: `buftype` is `acwrite` (schrijven loopt via
een `BufWriteCmd`, zie hieronder), dus splitsen met `CTRL-W` en springen met
gewone venstercommando's werkt. Hij staat wel op `buflisted = false`, dus hij
vervuilt je bufferlijst en je sessies niet.

## Openen

- Pad al bekend: `:e map/bestand` blijft sneller dan navigeren; Tab vult aan
- `nvim map/` of `:e map/` — opent oil (`default_file_explorer`)
- Sluiten met `<leader>e` zet de buffer terug die er stond, inclusief je
  scrollpositie — oil onthoudt dat in een venstervariabele

## Bewerken ís bestandsbeheer

Je bewerkt de buffer als tekst en slaat op met `:w`. Een regel wissen
verwijdert, een naam veranderen hernoemt, een regel toevoegen maakt aan.
Verplaatsen tussen mappen kan met knippen en plakken tussen twee oil-buffers.

Niets gebeurt vóór `:w`, dus tot dat moment is een misgrepen `dd` gewone tekst
en zet `u` hem terug zonder dat de schijf ooit is aangeraakt. Ná de write is
`u` géén vangnet meer: oil rendert de buffer dan opnieuw en de undo-historie
is weg ("Already at oldest change"). Daar vangt de prullenbak het op.

Er komt een bevestiging die opsomt wat er gaat gebeuren.
`skip_confirm_for_simple_edits` staat aan, dus die blijft weg bij kleine
ingrepen. Verwijderen valt daar nooit onder: de docs eisen dat de bewerkingen
"contain no deletes", hoogstens één verplaatsing en hoogstens vijf nieuwe
bestanden. Een misgrepen `dd` vraagt dus nog steeds om bevestiging.

Hernoemen laat jdtls de imports in je andere bestanden meelopen: oil stuurt
een `willRenameFiles` en past het antwoord toe. Daarvoor laadt hij ook buffers
van bestanden die je nooit opende, en die blijven met de default ongeslagen
achter — dan is de hernoeming gebeurd en de importfix niet. Vandaar
`autosave_changes = 'unmodified'`: dat schrijft precies die buffers weg, maar
laat een bestand waar jij zelf in bezig was met rust.

Verwijderde bestanden gaan naar de prullenbak van macOS
(`delete_to_trash`), niet naar de eigen prullenbak die mini.files gebruikte.
`g\` toont de prullenbak. Op macOS kan dat alleen als één map, niet per
oorspronkelijke locatie — Linux heeft daar wel volledige ondersteuning
(`:h oil-trash`).

## Wat er per bestand staat

Alleen een icoon en de naam, de default:

```
   .git/
󰉋  aerospace/
```

Er kan meer bij via `columns`: `permissions`, `size`, `mtime`, `atime`,
`ctime` en `birthtime`, elk met een eigen `highlight`, `align` en bij de tijden
een `format` in strftime-vorm (`:h oil-columns`). De rechtenkolom is
bewerkbaar — die rwx-tekst aanpassen en opslaan is een chmod.

De iconen komen van mini.icons, dat nvim-web-devicons vervangt.

Oil zet zelf `signcolumn` uit; hier staat hij weer aan, want het `%s` in de
'statuscolumn' (set.lua) valt anders weg en dan verspringen de regelnummers
ten opzichte van je andere vensters.

`show_hidden` staat aan. Zonder dat mist de verkenner `.gitignore` en
`.stylua.toml` in deze repo — dezelfde reden waarom `ripgreprc` `--hidden`
heeft. Per sessie omschakelen kan met `g.`.
