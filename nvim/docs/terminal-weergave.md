# Terminalweergave

Ghostty is mijn terminal. Deze keuzes horen bij [ghostty/config](../../ghostty/config)
en Ghostty 1.3.1; gecontroleerd tegen de meegeleverde handleiding op 15 september 2026.

## Font en kleuren

| Keuze | Waarom |
| --- | --- |
| MonaspiceNe Nerd Font Mono, 15.5 pt | Monaspace Neon met de iconen voor mijn Neovim-interface. |
| Regular, Bold, Italic en Bold Italic expliciet | De gewenste stijlen vastleggen; bij eerdere automatische fontselectie kwam Medium verkeerd terecht. |
| `font-feature = -liga, +calt` | Gewone ligaturen uit; Monaspace texture healing bewust aan, zodat lettervormen zich aan hun buren aanpassen. |
| `font-thicken = true` | Zonder verdikking oogde de tekst te dun. `font-thicken-strength` blijft op 255: de schaal loopt van 0 tot 255, niet van 0 tot 100. |
| `adjust-cell-width = 1` | Eén apparaatpixel extra geeft de gewenste ruimte tussen tekens. |

De celbreedte is op 13 september via `TIOCGWINSZ` gemeten: 3420 pixels / 180
kolommen = 19 pixels zonder aanpassing, 20 met `adjust-cell-width = 1`.
Die meting hoort bij 15.5 pt op het Retina-scherm; na een font- of schaalwijziging
opnieuw controleren. Texture healing kan ook gewone letters zoals `m` veranderen.

Het Nord-palet staat in de terminalconfig. Neovims eigen kleuren staan in
[nord.lua](../colors/nord.lua); een terminalthema vervangt die highlights niet.
De defaults `window-colorspace = srgb`, `alpha-blending = native` en
`background-opacity = 1` blijven behouden: sRGB-kleuren, de gekozen macOS-
tekstweergave en een ondoorzichtige achtergrond. Blending en vensterkleurruimte
zijn verschillende instellingen.

## Cursortrail

De [shader](../../ghostty/shaders/cursor_warp.glsl) is lokaal aangepast vanuit
`cursor_warp.glsl` van
[sahaj-b/ghostty-cursor-shaders](https://github.com/sahaj-b/ghostty-cursor-shaders)
(MIT). Vier hoeken bewegen afzonderlijk naar de nieuwe cursorpositie. De
voorste hoeken komen meteen aan; de achterste volgen met een gedempte veer.
Dat maakt grote sprongen zichtbaar zonder bij elke getypte letter een spoor.

- `DURATION = 0.15` en `TRAIL_SIZE = 1.0` geven de hoeken tijdschalen van
  0.15, 0.075, 0 en 0 seconden. Dit is geen harde eindtijd: de veer stopt zodra
  de resterende afwijking per as kleiner is dan 0.01 pixel.
- `SHORT_DURATION = 0.04` verkort kleine horizontale hoekbewegingen binnen een
  verder geanimeerde sprong. Een volledige cursorverplaatsing van maximaal
  twee cellen op dezelfde regel krijgt helemaal geen trail.
- `CELL_ASPECT = 20.0 / 39.0` reconstrueert de cel bij een balk of onderstreep.
  Dit past bij mijn font op 15.5 pt en Retina-schaal 2. Bij zoomen of een ander
  font kan die vaste verhouding afwijken.
- Een sprong met `A` of `I` blijft animeren wanneer tegelijk de cursorvorm
  verandert. Alleen van vorm wisselen op dezelfde positie geeft geen trail.
- De shader bewaart de echte cursorpixels en de bestaande alpha. Een verborgen
  cursor, ontbrekende vorige positie of oude sprong bij focuswisseling geeft
  geen spoor.

`custom-shader-animation = true` laat de animatielus alleen bij focus lopen.
`always` zou ook voor ongefocusseerde vensters blijven rekenen. De trail uitzetten:
comment de regels `custom-shader` en `custom-shader-animation` in de config.

Ghostty levert de huidige en vorige cursorrechthoek met een tijdstip, maar geen
bewaarde veersnelheid of vorige schermbeelden. Bij snel herhaalde bewegingen
kan de shader daardoor geen ononderbroken veerbeweging reconstrueren. Deze
shader animeert ook geen scrollende tekst.

De cursor knippert standaard niet. `adjust-cursor-thickness = 4` maakt de
balkcursor duidelijker: de basis van 1 pixel wordt 5 pixels. Neovim kiest de
cursorvorm per mode via `'guicursor'` in [set.lua](../lua/set.lua); de shader
voegt alleen het spoor toe.

## Vensters en bediening

- Geen decoratie, schaduw of padding: de terminal sluit aan op de
  [AeroSpace-indeling](../../aerospace/aerospace.toml). Zonder decoratie zijn
  ook de native macOS-tabs uit. `Cmd-N` maakt een venster; AeroSpace stapelt
  die op workspace 1 met `accordion`. `Hyper-h/j/k/l` verplaatst de focus.
- `keybind = clear` houdt alleen mijn eigen sneltoetsen over: `Cmd-C/V` voor
  het klembord, `Cmd-N` voor een venster, `Cmd-K/J` voor stappen van 0.5 pt en
  `Cmd-0` om het fontformaat te herstellen. Ook de standaard `Cmd-Q` vervalt.
  Afsluiten gaat via `exit` of `Ctrl-D`; het laatste gesloten venster sluit de app.
- `macos-option-as-alt = true` geeft Option door als Alt voor terminaltoetsen.
  `confirm-close-surface = false` slaat de sluitbevestiging over.
- `resize-overlay = never` voorkomt een overlay bij AeroSpace-layoutwissels;
  `progress-style = false` verbergt de voortgangsindicator. Updates gaan
  handmatig met `auto-update = off`.
- `mouse-scroll-multiplier = precision:1` behoudt de gewone trackpadsnelheid;
  de eerdere factor 3 was te snel. De muiswiel-default blijft 3.
  `mouse-hide-while-typing = true` houdt de aanwijzer uit de tekst tijdens typen.
- `copy-on-select = false` voorkomt dat selecteren het klembord vervangt.
- `shell-integration-features = no-cursor,sudo` voorkomt dat de shell het
  promptcursorblok in een balk verandert en bewaart `TERMINFO` bij `sudo`.
  Dat houdt de terminalmogelijkheden beschikbaar voor bijvoorbeeld `sudo nvim`.
- `bell-features = no-attention` voorkomt aandacht vragen via het Dock.
  Een commando dat minstens 15 seconden duurt geeft bij afronden alleen een
  melding als het venster geen focus heeft, met `no-bell,notify` zonder bel.

## Naslag en controle

De handleiding van de geïnstalleerde versie staat in
`/Applications/Ghostty.app/Contents/Resources/ghostty/doc/ghostty.5.md`.
`ghostty +show-config` toont de geladen instellingen; met `--default` de defaults.
`ghostty +validate-config` controleert de config.

Bij een font- of rendererupgrade: vergelijk dezelfde tekst op hetzelfde scherm
bij dezelfde zoom. Controleer kleurvlakken, normale/vette/cursieve tekst, iconen,
selectie en cursorsprongen afzonderlijk. Verander één instelling tegelijk;
beoordeel het resultaat op normale grootte.
