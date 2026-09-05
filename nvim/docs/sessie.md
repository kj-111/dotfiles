# De sessie per projectmap

Voer in een project één keer `:SessionCreate` uit om de huidige stand te
bewaren. Start je later `nvim` zonder argumenten in diezelfde map, dan staat
alles er weer: je buffers, de vensterindeling, de arglist en je folds.
Een sessie bewaart geen onopgeslagen tekst, dus schrijf wijzigingen eerst weg.
Zolang zo'n sessie actief is, staat het icoon `󰆓` in de statusline.

## Hoe het werkt

Twee autocmds en twee user commands in `lua/config/session.lua`. Geen plugin.

`VimEnter` herstelt, maar alleen in een verse nvim. Twee dingen moeten
kloppen: `argc() == 0`, want met `nvim Main.java` wil je dát bestand en
niet je vorige stand, én de buffer moet leeg en naamloos zijn. Dat tweede
is er voor `... | nvim -`: bij gepipete invoer is `argc()` óók nul, maar je
tekst staat al in de buffer en de sessie zou er dwars overheen laden.

Is het een verse start, dan wordt een bestaand sessiebestand voor deze map
gesourcet. Zonder bestaand bestand gebeurt niets: een nieuwe sessie ontstaat
alleen expliciet met `:SessionCreate`. Dat commando schrijft haar meteen en
activeert automatisch opslaan voor de rest van de Neovim-run.

Automatisch opslaan wordt pas actief nadat het sessiebestand volledig is
hersteld. Bevat het bestand een fout, dan blijft het dus onaangeroerd in plaats
van bij het afsluiten door een gedeeltelijk herstelde stand te worden vervangen.

`VimLeavePre` schrijft weg, via `:mksession!`, maar alleen als deze run een
bestaande sessie heeft hersteld of `:SessionCreate` is uitgevoerd. Alleen
`nvim een.lua` openen maakt dus niets aan en kan je projectsessie niet door
dat ene bestand vervangen.

Dat pad wordt één keer bepaald, bij het herstellen, en verandert daarna
niet meer. Doe je onderweg `:cd src`, dan verlegt dat het anker binnen je
sessie — je blijft naar hetzelfde sessiebestand schrijven. Zonder die
vastlegging zou je werk bij het afsluiten in `proj%src.vim` belanden en
bleef `proj.vim` op de stand van gisteren staan.

## Waar het staat

In `stdpath('state')/sessions`, dus `~/.local/state/nvim/sessions/`. Buiten
je project — er komt geen `Session.vim` in je repo die je moet gitignoren.

De bestandsnaam is de cwd met elke `/` vervangen door `%`:

```
~/academia/uni/java/prog1  →  %Users%jean%academia%uni%java%prog1.vim
```

Daarmee hangt de sessie aan de map waarin je nvim startte. `~/project` en
`~/project/src` zijn dus twee losse sessies. Het is de globale cwd,
`getcwd(-1, -1)`, dus een `:lcd` in één venster verlegt hem niet.

Het is een gewoon vimscript-bestand; je kunt het openen en lezen. Bovenin
staat `cd`, daaronder de `badd`-regels voor de buffers, dan `$argadd` voor
de arglist en per venster de `setlocal`-regels.

## Wat erin gaat

Dat bepaalt `'sessionoptions'` (set.lua). Die staat hier op de
nvim-default:

```
blank,buffers,curdir,folds,help,tabpages,winsize,terminal
```

Uit `:h 'sessionoptions'`, letterlijk:

- `buffers` — "hidden and unloaded buffers, not just those in windows"
- `folds` — "manually created folds, opened/closed folds and local fold
  options"
- `curdir` — de cwd; `blank` — naamloze vensters; `help` — het helpvenster
- `tabpages` — alle tabs, niet alleen de huidige
- `winsize` — de venstergroottes, relatief aan het scherm
- `terminal` — "include terminal windows where the command can be restored"

Twee dingen staan er los van en komen altijd mee. De arglist: in het
sessiebestand zie je `$argadd` per bestand en `3argu` voor welke de huidige
was. En de cursorposities — `:h :mksession` punt 7: "Reloads the buffer
list, with the last cursor positions."

Folds zijn hier de stille winst. Vouw je een Java-bestand dicht tot een
lijst methodes met `zM`, of klap je één klasse open, dan is dat er morgen
nog. Zonder `folds` in de lijst begin je elke sessie weer met alles open
(folds.md).

De terminal-split komt terug, maar leeg: in het sessiebestand staat de
buffer als `term://...//4549:/bin/zsh`, dus alleen het commando. Je krijgt
een verse shell, geen scrollback.

## Wat er niet in gaat

`options` staat er bewust niet bij — die zou álle opties en mappings
meeschrijven, en init.lua zet ze bij het starten toch opnieuw. Opgeslagen
waarden botsen daar alleen maar mee. De help waarschuwt wel voor de andere
kant op: "If you leave out 'options' many things won't work well after
restoring the session." Hier valt dat mee, omdat de config zelf de opties
zet.

Marks, registers en de zoekgeschiedenis zitten er ook niet in. Die gaan via
shada (`:h shada`) en zijn globaal, niet per map. De undo-historie staat
weer ergens anders, in `'undofile'` (set.lua).

## :restart doet zijn eigen sessie

`:restart` (en `ZR`) is nieuw in 0.12 en regelt dit zelf: "1. Saves the
current session", "4. Restores the saved session" (`:h :restart`). Dat is
een eigen tijdelijk sessiebestand, los van het onze.

Twee opzetten die tegelijk herstellen klinkt als een botsing, dus nagemeten
met een echte terminal: vóór de restart vijf vensters met `A.java`, erna
precies dezelfde vijf. Geen verdubbeling, niets kwijt. Onze `VimLeavePre`
schrijft onderweg gewoon mee, want `:restart` stopt nvim via `:qall`.

Wil je weten in welke van de twee je zit: `v:startreason` is `"restart"` in
plaats van `"normal"`, en `v:exitreason` doet hetzelfde bij het afsluiten.

## Wat andere opzetten wél doen, en hier niet

persistence.nvim filtert voor het opslaan de buffers: alles met een
`'buftype'` eruit, `gitcommit` en `gitrebase` eruit, en niets wegschrijven
onder een minimum aantal echte bestanden. Dat is hier nagemeten en niet
overgenomen.

`:mksession` schrijft inderdaad een genoemde scratch-buffer weg als
`badd`-regel, en bij het herstellen krijg je die dan terug als leeg,
niet-bestaand bestand. Maar dat geldt alleen voor buffers met
`'buflisted'`. De plugins hier maken die niet: mini.files gebruikt
`nvim_create_buf(false, true)` met `bufhidden=wipe`, dus niet in de lijst
en weg zodra je hem sluit. Het quickfix-venster komt sowieso niet in de
sessie. En `gitcommit` hoeft niet gefilterd: `git commit` start nvim mét
een argument, dus daar herstelt en bewaart hij toch al niets.

Open je nvim ergens en sluit je meteen af, dan ontstaat er geen leeg
sessiebestand: alleen `:SessionCreate` maakt een nieuwe sessie.

mini.sessions (zit in de mini.nvim die je al laadt) stelt dezelfde vraag
als wij bij het opstarten, in `H.is_something_shown()`, maar met vier
checks: `argc() > 0`, meer dan één buffer in de lijst, de buffer heeft een
`'filetype'`, of hij heeft inhoud. Wij doen er drie — `argc`, naamloos, en
leeg. De twee die we missen dekken een startbuffer die een ander al gevuld
heeft; hier maakt niets dat, dus ze zijn niet overgenomen.

Net als mini.sessions maken we nu alleen op commando een nieuwe sessie. De
eigen `session_path` blijft wel het opslaganker van precies de projectsessie
die onze config heeft geladen of gemaakt; een losse `:mksession` verandert
dat anker niet.

En hun opzet is een goede herinnering dat dit ook helemaal handmatig kan:
één map met benoemde sessies die je met een picker uitkiest. Dat blijft een
andere workflow — hier loopt per project één sessie automatisch mee nadat je
haar met `:SessionCreate` hebt aangezet.

## Twee nvims in dezelfde map

Dan wint wie het laatst afsluit. Beide lezen bij het starten hetzelfde
bestand, beide schrijven het bij het afsluiten, en de tweede overschrijft
wat de eerste bewaarde. Dit zit in het ontwerp van elke mksession-opzet;
auto-session lost het ook niet op.

Praktisch valt het mee zolang je per map één nvim openhoudt. Wil je er
tijdelijk een tweede bij voor één bestand, start die dan met een argument
(`nvim Main.java`) — die herstelt niets en schrijft niets weg.

## Opnieuw beginnen

`:SessionDelete` verwijdert het sessiebestand én zet het opslaganker uit, dus
hij blijft weg. Alleen het bestand weghalen is niet genoeg zolang de sessie
actief is: `VimLeavePre` schrijft haar bij het afsluiten prompt terug
(nagemeten). Startte je met een argument, dan is er niets hersteld en wist het
commando enkel het bestand.

Wil je alleen de arglist kwijt en de rest houden: `:%argdel` en afsluiten.
