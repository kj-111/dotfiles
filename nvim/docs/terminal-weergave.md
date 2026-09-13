# Alacritty-weergave behouden: Ghostty, kitty en foot

> Onderzocht op 10 september 2026, met Alacritty als referentie. Op 13 september
> is Ghostty de terminal geworden en zijn Alacritty en kitty verwijderd.
> Alacritty blijft de maatstaf waaraan de weergave is afgemeten; dat is wat dit
> document bewaart. De rest staat zoals het toen is vastgesteld.

Dit begon als naslag voor een eventuele overstap. De uitkomsten staan hieronder
in de volgorde waarin ze zijn vastgesteld; de laatste is de huidige stand.

## Uitkomst: kitty, 11 september 2026

Kitty is geïnstalleerd, ingericht en visueel beoordeeld, en op 13 september
weer volledig verwijderd — de branch is weg bij beide remotes. Wat hier staat
bleef relevant, want Ghostty liep tegen dezelfde vragen aan.

Display P3 bleek wél de oplossing. Niet omdat het onderzoek fout was, maar
omdat de referentie verschoof. Met Alacritty als doel is `srgb` correct — die
tagt zijn venster hard als sRGB, zonder optie. Neovide tagt óók, maar op macOS
standaard als `deviceRGB`: dan converteert het systeem niet en landen dezelfde
RGB-waarden in het kleurbereik van het scherm zelf, wat op P3 voller oogt. Blauw
`#81a1c1` was daar het duidelijkst. Zodra Neovide de referentie werd in plaats
van Alacritty, draaide het advies om naar `macos_colorspace displayp3`.

De drie apps gaan dus fundamenteel anders met kleur om, en dat verklaart
waarom ze nooit gelijk kónden zijn:

| app       | kleurbeheer                    | instelbaar              |
| --------- | ------------------------------ | ----------------------- |
| Alacritty | tagt het venster hard als sRGB | nee                     |
| Neovide   | tagt, standaard `deviceRGB`    | ja, `srgb`              |
| kitty     | tagt, standaard sRGB           | ja, `macos_colorspace`  |
| Ghostty   | tagt, standaard sRGB           | ja, `window-colorspace` |

Verder uit de praktijk:

- `text_composition_strategy 1.7 55`, tegen de macOS-default `1.7 30`. Het
  eerste getal blijft: gamma raakt vooral donkere tekst op licht en doet bij
  Nord bijna niets. Deze instelling herlaadt niet live.
- Texture healing uit, en dat bevestigt de waarschuwing hieronder: de `m` oogde
  meteen vreemd. In het fontbestand zelf nagegaan — `calt` roept lookups 159 tot
  163 aan, die `m` vervangen door `m.both`, `m.left` of `m.right` afhankelijk
  van de buren. In Alacritty zag je dat nooit, want die shapet niet. In Neovide
  blijft het bewust aan.
- Alle vier de faces expliciet opgeven, niet `bold_font auto`. Monaspace zet
  elke weight in een eigen familie, dus kitty's automatische keuze landde op
  `MonaspiceNeNFM-Medium` in plaats van `-Bold`. Nagemeten met kitty's eigen
  fontresolutie; `kitten choose-fonts` toont hetzelfde.

## Omgedraaid: Neovide naar Alacritty, 13 september 2026

Alacritty is de referentie voor de weergave, ook nu Ghostty de terminal is die
draait. Daarom staat `srgb = true` in `neovide/config.toml`. Neovide roept dan
`NSColorSpace::sRGBColorSpace()` aan — letterlijk dezelfde aanroep die Alacritty
hardgecodeerd doet — in plaats van `deviceRGBColorSpace()`:

```rust
// neovide 0.16.2, src/renderer/metal.rs:95
ns_window.setColorSpace(Some(
    if srgb { NSColorSpace::sRGBColorSpace() } else { NSColorSpace::deviceRGBColorSpace() }
        .as_ref(),
));
```

Op de Metal-pad, die macOS standaard neemt, is dat het enige wat de vlag doet;
de Skia-surface staat er los van en gebruikt altijd `ColorSpace::new_srgb()`.
De hulptekst ("may help with GPUs with weird pixel formats") verwijst naar de
OpenGL-pad en zegt niets over wat de vlag hier uitricht.

## Uitkomst: ghostty, 13 september 2026

Ghostty 1.3.1 is de terminal geworden. De config wordt gelezen vanaf
`~/.config/ghostty/config`, dus net als bij alacritty is er geen symlink nodig.
Nagegaan met `ghostty +show-config`.

De celbreedte is gemeten in plaats van geschat, via `TIOCGWINSZ` in alle drie de
terminals, met hetzelfde font op 15.5 pt:

| app       | xpixel | kolommen | celbreedte |
| --------- | ------ | -------- | ---------- |
| Alacritty | 1600   | 80       | 20 px      |
| kitty     | 3420   | 171      | 20 px      |
| Ghostty   | 3420   | 180      | 19 px      |

Ghostty rondt dus af zoals Alacritty zónder `font.offset`, niet zoals kitty.
`adjust-cell-width = 1` haalt hem naar 20. Die eenheid is apparaatpixels en geen
punten; ook dat is nagemeten, want op een retinascherm was 19 → 21 net zo
aannemelijk geweest.

Wat verder afwijkt van kitty:

- `window-decoration = none` schakelt op macOS ook de tabs uit. Dat dwingt het
  systeem af, dus een aparte tab-optie is overbodig.
- `font-feature` geldt voor alle faces tegelijk; kitty heeft er vier regels voor.
- `scrollback-limit` staat in bytes, niet in regels, met 10 MB als default.
  Alacritty's `history = 10000` letterlijk overnemen zou 10 kB scrollback geven.
- `copy-on-select` staat op macOS standaard aan, in Alacritty niet.
- `keybind = clear` wist ook `super+q=quit`. Afsluiten gaat nu via `exit` of
  `CTRL-D`, want `quit-after-last-window-closed` staat aan.
- De `sudo`-feature van de shell-integratie staat standaard uit; bij kitty aan.
  Die is hier geen luxe: ghostty's terminfo zit alleen in de app-bundel en niet
  in de systeempaden, en de wrapper zet `--preserve-env=TERMINFO`. Zonder die
  feature verliest `sudo nvim` undercurl (`Smulx`) en truecolor (`setrgbf`).
- `resize-overlay` staat standaard op `after-first` en zou bij elke
  aerospace-layoutwissel opflitsen.
- `mouse-scroll-multiplier` scheidt trackpad (`precision`, default 1) van muis
  (`discrete`, default 3). Alleen de eerste moest naar 3.

De vier faces expliciet opgeven is hier net zo nodig, en de oorzaak is nu
scherper: de Medium-face van Monaspace adverteert nameID 2 = "Regular" en zet
"Medium" pas in nameID 17. Wie op nameID 2 matcht ziet Medium dus als een gewone
Regular staan, wat verklaart hoe kitty hem als bold kon kiezen.

De tekst oogde dunner dan in Alacritty, en dat is geen inbeelding. Beide
rasteren via CoreGraphics en zetten daar één vlag verschillend:

```rust
// alacritty, crossfont/src/darwin/mod.rs
cg_context.set_should_smooth_fonts(*FONT_SMOOTHING_ENABLED);  // ongezet = true
```

```zig
// ghostty 1.3.1, src/font/face/coretext.zig:483
context.setShouldSmoothFonts(ctx, opts.thicken);              // default false
```

Alacritty's eigen comment noemt het effect: font smoothing "increases the stroke
width". Vandaar `font-thicken = true`. Aan `font-thicken-strength` valt niets te
draaien: die zet de grijswaarde van de vulling, en de default 255 is wit —
precies wat Alacritty met `set_rgb_fill_color(1.0, 1.0, 1.0, 1.0)` doet.

De balkcursor is `adjust-cursor-thickness = 4`. Ghostty's basis is 1 px
(`Metrics.zig`, "not determined by fonts but rather by user configuration"), en
Alacritty tekent `0.25 × 20 px = 5`.

De cursor trail is `shaders/cursor_warp.glsl`, MIT, uit
[sahaj-b/ghostty-cursor-shaders](https://github.com/sahaj-b/ghostty-cursor-shaders).
Die is gekozen omdat hij Neovide's model volgt en niet dat van kitty: vier
hoeken met een eigen duur, en een open lus via `iTimeCursorChange`. Neovide's
formule staat er letterlijk in:

```rust
// neovide, cursor_renderer/mod.rs:172
let leading = animation_length * (1.0 - trail_size);
match rank { 2..=3 => leading, 1 => (leading + trailing) / 2.0, 0 => trailing }
```

`DURATION` en `TRAIL_SIZE` zijn in de shader op Neovide's defaults gezet, 0.15
en 1.0. `custom-shader-animation = always` is nodig omdat de cursor bij
focusverlies hol wordt en de animatie anders bevriest.

Alternatieven bekeken en afgevallen: `boo`/`tinkle`/`wisp`
([hced](https://github.com/hced/ghostty-cursor-trails)) splitsen de hoeken via
`LEAD_EDGE_LAG` en tekenen gebogen banen; `smear_cursor_blocks` en `cursor_tail`
gebruiken een gesloten lus, hetzelfde model als kitty; `cursor_blaze` is een
vlameffect met vaste kleur.

## De referentie

De weergave die hieronder beschreven staat, is die van Alacritty 0.17.0 — de
maatstaf waaraan alles is afgemeten. Alacritty zelf is op 13 september
verwijderd, dus dit is wat ervan bewaard is gebleven; de werkende versie staat
in [ghostty/config](../../ghostty/config) en [nord.lua](../colors/nord.lua).
Behoud bij een vergelijking:

- `MonaspiceNe Nerd Font Mono`, 15.5 pt; Regular, Bold, Italic en Bold Italic.
  Gebruik dezelfde geïnstalleerde fontbestanden, niet zomaar een andere
  Monaspace/Nerd Fonts-versie met een vergelijkbare naam.
- Achtergrond `#2e3440`, voorgrond `#d8dee9`.
- Selectieachtergrond `#4c566a`, selectietekst `#eceff4`.
- Cursorkleur `#88c0d0`, tekst onder de cursor `#2e3440`.
- Geen extra helderheid voor bold, geen padding, opacity `0.9999`.

Het exacte ANSI-palet staat hieronder. Alleen overal een thema met de naam
“Nord” kiezen is geen garantie op dezelfde waarden.

| ANSI-kleur | Normaal, index 0–7 | Bright, index 8–15 |
| ---------- | ------------------ | ------------------ |
| zwart      | `#3b4252`          | `#4c566a`          |
| rood       | `#bf616a`          | `#bf616a`          |
| groen      | `#a3be8c`          | `#a3be8c`          |
| geel       | `#ebcb8b`          | `#ebcb8b`          |
| blauw      | `#81a1c1`          | `#81a1c1`          |
| magenta    | `#b48ead`          | `#b48ead`          |
| cyaan      | `#88c0d0`          | `#8fbcbb`          |
| wit        | `#e5e9f0`          | `#eceff4`          |

Neovims kleurenbestand zet `termguicolors` aan en definieert zelf de RGB-highlights
en het `:terminal`-palet. Alleen het terminalthema wijzigen verandert dus niet
automatisch de syntaxkleuren van mijn editor.

## Eerst onderscheid maken

1. **Kleurwaarden:** zijn achtergrond, voorgrond en palet werkelijk gelijk?
2. **Kleurruimte:** hoe worden die RGB-getallen geïnterpreteerd?
3. **Tekstrendering:** rasterisatie, blending en fontgewicht bepalen de randen
   en waargenomen dikte van letters.
4. **Fontvormen:** shaping kan andere glyphs kiezen, ook bij hetzelfde font.

Alacritty 0.17.0 stelt op macOS expliciet sRGB in. Daarom is sRGB het logische
vertrekpunt voor deze vergelijking, niet Display P3. Een groter kleurbereik is
geen automatische verbetering als het doel dezelfde kleuren is.
[Broncode van deze Alacritty-versie](https://github.com/alacritty/alacritty/blob/v0.17.0/alacritty/src/display/window.rs#L527).

## Ghostty: beoordeling van de gedeelde tips

| Tip                                 | Wat doet hij?                                          | Voor mijn referentie                                           |
| ----------------------------------- | ------------------------------------------------------ | -------------------------------------------------------------- |
| `window-colorspace = display-p3`    | Interpreteert RGB als Display P3 in plaats van sRGB.   | Niet overnemen; begin met `srgb`.                              |
| `alpha-blending = linear-corrected` | Lineaire blending met correctie voor de tekstweergave. | Legitieme A/B-test, geen bewezen Alacritty-match.              |
| `font-thicken = true`               | Verdikt letters op macOS.                              | Alleen testen als letters na de basisvergelijking te dun zijn. |
| `font-thicken-strength = 70`        | Sterkte van die verdikking, geen percentage.           | Geldige waarde, geen universele optimale waarde.               |

De macOS-defaults in Ghostty 1.3.1 zijn `srgb`, `native` blending en
`font-thicken = false`. De sterkte heeft bereik 0–255, default 255, en doet niets
zolang verdikking uitstaat. Zelfs 0 betekent bij ingeschakelde verdikking niet
“uit”. Blending en kleurruimte zijn verschillende instellingen.
[Optiereferentie](https://ghostty.org/docs/config/reference#alpha-blending),
[getagde defaults](https://github.com/ghostty-org/ghostty/blob/v1.3.1/src/config/Config.zig).

Begin dus met hetzelfde font, palet en de standaardrendering. Wijzig daarna
hoogstens één renderingoptie tegelijk; zet niet alle vier tips tegelijk aan.
Er is geen onderbouwd recept waarmee die combinatie exact Alacritty wordt.

### Is dit eerder gemeld?

Ja. [Discussie #2363](https://github.com/ghostty-org/ghostty/discussions/2363)
bespreekt sRGB versus P3 en fontverdikking.
[PR #4202](https://github.com/ghostty-org/ghostty/pull/4202) vertrok juist vanuit
kleuren die sterker oogden dan Terminal.app bij gelijke hexwaarden. Dat is een
andere referentie en zelfs de tegenovergestelde klacht van “flets”. Het is geen
bewijs dat P3 voor mijn setup beter is.

[Discussie #3932](https://github.com/ghostty-org/ghostty/discussions/3932) gaat
over Linux/HDR. Zulke meldingen niet zonder meer vertalen naar een Mac.
Een melding bevestigt dat iemand een verschil ziet, niet dat alle versies en
schermen dezelfde oorzaak of oplossing hebben.

## kitty

Begin met `macos_colorspace srgb`, `text_composition_strategy platform` en
`macos_thicken_font 0`: de gedocumenteerde defaults. Neem daarnaast mijn exacte
font en kleuren over. Gebruik `kitten choose-fonts` om de faces te controleren.

Bij afwijkende letterdikte is `text_composition_strategy` de relevante instelling.
`legacy` maakt doorgaans lichte tekst op donker dunner, maar kan onregelmatige
strokes geven. Numerieke waarden sturen gamma en extra contrast; de beschreven
macOS-default is `1.7 30`. Dit is geen equivalente schaal voor Ghostty's `70`.
Herstart kitty bij zo'n vergelijking: deze compositie-instelling is niet live
herlaadbaar. Display P3 is niet het uitgangspunt voor een sRGB-match — maar zie
de uitkomst bovenaan: met Neovide als referentie werd het juist de oplossing.
[kitty-configreferentie](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.text_composition_strategy).

Ook hierover bestaan directe vergelijkingen met Alacritty:
[issue #6643](https://github.com/kovidgoyal/kitty/issues/6643) beschrijft minder
scherpe tekst op een 1080p-scherm; de maker verwijst naar
`text_composition_strategy` voor persoonlijke afstemming.
[Issue #2580](https://github.com/kovidgoyal/kitty/issues/2580) meldt juist te dunne
fonts. Dit zijn historische gebruikerservaringen, geen vaststaand oordeel over
de huidige versie of mijn scherm.

## foot

foot is een native Wayland-terminal, geen native macOS-app. Voor mijn huidige
Mac dus geen rechtstreekse kandidaat. Alleen relevant bij een latere overstap
naar een Wayland-desktop; een VM is geen eerlijke macOS-rendervergelijking.
[Upstream README](https://codeberg.org/dnkl/foot/src/branch/master/README.md).

Daar begint de vergelijking met dezelfde fontbestanden en Nord-waarden.
foot gebruikt Fontconfig-fontspecificaties, bijvoorbeeld
`font=MonaspiceNe Nerd Font Mono:size=15.5`. Controleer ook DPI/scaling: dezelfde
puntgrootte hoeft op een andere desktop geen gelijk pixelraster te geven.

`gamma-correct-blending` staat volgens de huidige handleiding standaard op `no`.
`yes` maakt lichte tekst op donker doorgaans dikker en donkere tekst op licht
dunner. Het kan ook duurdere buffers met hogere kleurprecisie gebruiken.
Niet automatisch inschakelen om Alacritty na te bootsen, en geen
`surface-bit-depth`-tweaks toevoegen zonder concrete aanleiding.
[Upstream handleiding](https://codeberg.org/dnkl/foot/src/branch/master/doc/foot.ini.5.scd).

Er waren echte kleurproblemen: de
[changelog](https://codeberg.org/dnkl/foot/src/branch/master/CHANGELOG.md)
vermeldt een gamma-blendingfix in 1.22.2, gekoppeld aan issue #2035, en een
defaultwijziging naar `no` in 1.22.3. Oudere adviezen kunnen daardoor achterhaald
zijn. Dit bewijst geen huidig probleem in foot.

## Monaspace: niet verwarren met mijn Neovide-keuze

Alacritty gebruikt hier geen OpenType-shaping; zie ook [neovide.md](neovide.md).
In Neovide staat texture healing bewust aan. Dat is niet de referentie voor
deze vergelijking: nu gaat het om mijn terminalweergave.

Monaspace koppelt texture healing aan `calt`. Ghostty en kitty kunnen zulke
features toepassen. Voor een Alacritty-gerichte vergelijking dus eerst zonder
texture healing en extra ligaturen testen. In Ghostty kan dat via
`font-feature = -calt, -liga, -dlig`; in kitty via de font-featureselectie.
Alleen “ligaturen uit” noemen is te onnauwkeurig: texture healing verandert
ook gewone lettervormen. Controleer bij een toekomstige fontupgrade opnieuw.
[Monaspace-documentatie](https://github.com/githubnext/monaspace#texture-healing),
[Ghostty font-feature](https://ghostty.org/docs/config/reference#font-feature),
[kitty font features](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.font_features).

## Vergelijkingsprocedure bij een echte overstap

1. Laat mijn huidige Alacritty-config intact. Start de kandidaat met een aparte
   minimale testconfig; noteer appversie, fontversie, scherm en schaalfactor.
2. Gebruik hetzelfde scherm, dezelfde achtergrond, helderheid en systeemkleur-
   instellingen. Geen blur of shaders. Test actieve vensters na elkaar zodat
   eventuele inactieve-window-dimming geen verschil veroorzaakt.
3. Vergelijk eerst effen kleurvlakken, daarna letters. Onderstaande test gebruikt
   expliciete RGB-kleuren en geen thema-afhankelijk ANSI-palet:

    ```sh
    printf '\033[48;2;46;52;64m\033[38;2;216;222;233m Normal Il1 O0 != -> ffi \033[0m\n'
    printf '\033[48;2;46;52;64m\033[38;2;136;192;208m Cyan   Il1 O0 != -> ffi \033[0m\n'
    printf '\033[48;2;136;192;208m        \033[0m\n'
    ```

4. Vergelijk daarna hetzelfde bestand in Neovim, met hetzelfde colorscheme,
   vensterformaat en zoomniveau. Controleer bold, italic, comments, selectie,
   cursor, box-drawing en Nerd Font-iconen. Een gelijk font garandeert niet
   dezelfde ingebouwde lijntekeningen of fallbackglyphs.
5. Pas alleen de kandidaat aan: eerst palet/kleurruimte, dan fontfaces en shaping,
   pas daarna blending of verdikking. Een bijna-ondoorzichtige achtergrond
   (`0.9999`) en een volledig ondoorzichtige (`1`) zijn technisch niet identiek;
   houd achtergrond en transparantie ook bij die laatste controle gelijk.
6. Beoordeel op normale grootte. Vergrote screenshots helpen bij rasterdetails,
   maar een gecomprimeerde of herschaalde online afbeelding bewijst geen match.
   Geen garantie op pixelidentieke weergave tussen verschillende renderers.

## Conclusie en verificatiegrens

De aanpak hierboven klopte: eerst dezelfde kleuren en fontbestanden, daarna één
renderingoptie tegelijk. Alleen het eindpunt is anders geworden, omdat de
referentie halverwege verschoof van Alacritty naar Neovide — zie de uitkomst
bovenaan. De les is niet "P3 is beter", maar dat het antwoord afhangt van
waarmee je vergelijkt, en dat je die keuze expliciet moet maken vóór je afstelt.

foot blijft een Wayland-optie, geen Mac-migratieplan. Ghostty is niet getest;
die had voor de cursor trail een externe GLSL-shader nodig, en die trail is
uiteindelijk toch niet gebruikt.

Het onderzoek van 10 september is gecontroleerd tegen lokale configuratie,
upstreamdocumentatie, Ghostty 1.3.1- en kitty 0.48.2-broncode en historische
meldingen — toen zonder installatie. Kitty is daarna wél geïnstalleerd en
visueel beoordeeld; Ghostty en foot niet. De online docs en foot `master`
kunnen veranderen: verifieer bij installatie de meegeleverde handleiding.
