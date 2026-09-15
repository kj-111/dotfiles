# Alacritty-weergave behouden: Ghostty, kitty en foot

> Onderzocht op 10 september 2026, met Alacritty als referentie. Op 13 september
> is Ghostty de terminal geworden en zijn Alacritty en kitty verwijderd.
> Alacritty blijft de maatstaf waaraan de weergave is afgemeten; dat is wat dit
> document bewaart. De rest staat zoals het toen is vastgesteld.

Dit begon als naslag voor een eventuele overstap. De uitkomsten staan hieronder
in de volgorde waarin ze zijn vastgesteld; de laatste is de huidige stand.

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

Alternatieven bekeken en afgevallen: `boo`/`tinkle`/`wisp`
([hced](https://github.com/hced/ghostty-cursor-trails)) splitsen de hoeken via
`LEAD_EDGE_LAG` en tekenen gebogen banen; `smear_cursor_blocks` en `cursor_tail`
gebruiken een gesloten lus, hetzelfde model als kitty; `cursor_blaze` is een
vlameffect met vaste kleur.

### De shader tegen de bron gelegd

Op 14 september opnieuw gecontroleerd tegen **Neovide 0.16.2** en **Ghostty
1.3.1**. Neovides cursorcode is de referentie; Ghostty bepaalt welke gegevens
de shader krijgt. De uitleg staat hier, de shader bevat alleen de gebruikte
logica en de oorspronkelijke herkomstvermelding.

De vorige shader gebruikte al de juiste duur en veerformule, maar miste deze
details:

| onderdeel         | huidige werking                                                                                            | bron                                                            |
| ----------------- | ---------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| hoekvolgorde      | linksboven, rechtsboven, rechtsonder, linksonder; bij gelijke uitlijning beslist deze index                | `STANDARD_CORNERS` en `corner_ranks`                            |
| balkcursor        | richting van iedere hoek gemeten vanuit het midden van de volledige tekstcel                               | `set_cursor_shape()` en `calculate_direction_alignment()`       |
| leidende hoeken   | duur nul betekent onmiddellijk op de bestemming, ook op het eerste shaderframe                             | `CriticallyDampedSpringAnimation::update()`                     |
| einde van de veer | iedere as stopt onder 0,01 pixel; geen vaste afkapduur                                                     | dezelfde functie                                                |
| pixelraster       | hoeken worden vóór het tekenen afgerond, halve pixels van nul af                                           | `draw_rectangle()`                                              |
| randen            | dekking rond de rand, zonder de vroegere blur van één pixel naar buiten                                    | `paint.set_anti_alias(true)`; de shader benadert Skia's dekking |
| zichtbaarheid     | geen trail bij verborgen cursor, ontbrekende vorige cursor of een beweging van vóór de laatste focuswissel | Ghostty-uniforms                                                |

De hoekvolgorde was op macOS verticaal gespiegeld. Ghostty gebruikt daar
`custom_shader_y_is_down = true` en geeft met `iCurrentCursor.xy` de
**linkeronderhoek** door. De oude shader behandelde die als linksboven.
De rechthoek lag nog goed, maar bij een sprong naar rechts kreeg linksonder
de langste staart. Neovide geeft die aan linksboven. De shader rekent nu
rechtstreeks in pixels met dezelfde Y-richting als Neovide.
[Neovide: hoeken en sortering](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L26),
[Ghostty: Metal-as](https://github.com/ghostty-org/ghostty/blob/v1.3.1/src/renderer/Metal.zig#L34),
[Ghostty: cursorcoördinaten](https://github.com/ghostty-org/ghostty/blob/v1.3.1/src/renderer/generic.zig#L2141).

Voor een sprong vanuit stilstand is de resterende afstand:

```text
offset(t) = delta × (1 + omega × t) × exp(-omega × t)
omega = 4 / duur
```

Bij lange hoekreizen blijven de duren 0,15 s voor de achterste hoek, 0,075 s
voor de tussenhoek en 0 s voor de twee voorste hoeken. De oude grens van
2,5 × 0,15 s liet bij een
sprong van 3000 pixels nog ongeveer 1,5 pixel over en kapte dat ineens af.
Nu volgt iedere as Neovides grens van 0,01 pixel. Samenvallende afgeronde
hoeken veroorzaken bovendien geen deling door nul meer in de afstandsfunctie.
[Neovide: veer en stopgrens](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/animation_utils.rs#L89),
[duur per hoek](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L156),
[pixelafronding](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L537).

### Wat een Ghostty-shader niet kan overnemen

Neovide bewaart de actuele positie én snelheid van iedere hoek. Bij een nieuwe
sprong blijft de snelheid staan. Ghostty geeft alleen de vorige en huidige
cursorrechthoek door; `iChannel0` bevat het huidige scherm, geen vorig frame.
De golf bij ingedrukte `j/k` is daardoor niet exact te reconstrueren. Deze
shader berekent elke sprong vanuit stilstand. Ook Neovides herstel na een lang
frame (`animation_length <= dt`) heeft toestand nodig om daarna niet opnieuw
halverwege de beweging te verschijnen.
[Neovide: bestemming veranderen](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L124),
[Ghostty: beschikbare uniforms](https://github.com/ghostty-org/ghostty/blob/v1.3.1/src/renderer/shaders/shadertoy_prefix.glsl).

Korte horizontale sprongen tot twee cellen blijven zonder trail. Neovide
verplaatst dan de hele cursor met een veerduur van 0,04 s. Ghostty heeft die
cursor al op zijn bestemming getekend; een extra schuivende rechthoek zou
twee cursors opleveren. De shader behoudt daarom de echte cursorpixels en
tekent alleen buiten die rechthoek. Dit is een bewuste benadering, geen
identieke uitvoering van Neovides korte animatie.

Een sprong met tegelijk een vormwissel animeert wel: bijvoorbeeld `A` vanaf
het begin van een lange regel, waarbij het blok een insert-balk wordt. Iedere
hoek vertrekt uit de vorige cursorrechthoek en beweegt naar zijn eigen nieuwe
bestemming, zoals in Neovides `Corner::update()`. De aanvankelijke controle
die alle formaatwissels oversloeg, blokkeerde ook deze gewone beweging en is
verwijderd. Een vormwissel zonder verplaatsing blijft zonder extra trail.

Neovide heeft geen aparte `A`-animatie. `set_cursor_shape()` wijzigt de
relatieve vorm en bewaart de bestaande hoeken met `..corner`. Daarna berekent
`Corner::update()` voor iedere hoek zijn eigen afstand. Ook de korte duur
van 0,04 s wordt in `Corner::jump()` per hoek gekozen: bij het versmallen
van een brede blokcursor kan één hoek minder dan twee cellen reizen terwijl
de andere verder gaan. Beide details zitten nu in de shader.
[Vormwissel](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L265),
[afstand per hoek](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L124),
[duur per hoek](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L156).

De verdere broncontrole bevestigde dat insert- en commandoregelanimatie
standaard aanstaan. Dubbelbrede blokcursors volgen hun doorgegeven
rechthoekmaat. Smooth blink staat standaard uit en de VFX-lijst is leeg:
er ontbreekt geen standaard deeltjes- of fade-effect.
[Defaults en dubbele breedte](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L72),
[lege VFX-default](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/cursor_vfx.rs#L55).

Neovides venster-ID, viewportmarges en lopende scrollanimatie ontbreken in de
Ghostty-uniforms. Ook tekent Neovide de cursorletter opnieuw, geclipt aan het
bewegende pad; de shader bewaart de al getekende Ghostty-cursor. Blinken en de
unfocused outline blijven van Ghostty. Een kleurwissel reset bovendien
Ghostty's bewegingsuniforms, terwijl Neovide zijn bestaande beweging kan
voortzetten. Die verloren geschiedenis is niet uit de twee resterende
cursorrechthoeken te herstellen.
[Venster en scroll](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L294),
[cursor tekenen](https://github.com/neovide/neovide/blob/0.16.2/src/renderer/cursor_renderer/mod.rs#L336),
[Ghostty: kleurwissel](https://github.com/ghostty-org/ghostty/blob/v1.3.1/src/renderer/generic.zig#L2198).

Een blokcursor levert zijn celmaat rechtstreeks. Bij een balk of underscore
ontbreekt één celafmeting in de uniforms. `CELL_ASPECT = 20.0 / 39.0` vult die
aan voor de huidige MonaspiceNe Nerd Font Mono op 15,5 pt en Retina-schaal 2.
Nagerekend uit het lokale font: 2000 units/em, advance 1240, typo-ascent 1990
en descent −500. Op 31 pixels/em geeft dat 19,22 × 38,595 pixels; Ghostty rondt
naar 19 × 39 en `adjust-cell-width = 1` maakt er 20 × 39 van. Bij een andere
zoom, schaal of font kan deze verhouding afwijken.
[Ghostty: fontmetrics](https://github.com/ghostty-org/ghostty/blob/v1.3.1/src/font/face/coretext.zig#L642),
[afronding](https://github.com/ghostty-org/ghostty/blob/v1.3.1/src/font/Metrics.zig#L265).

De kleuren blijven ongewijzigd: met de huidige `alpha-blending = native`
gebruikt Ghostty `bgra8unorm`, zodat hier geen sRGB-naar-lineairconversie
hoort. De achtergrondalpha blijft behouden.
[Ghostty: pixelformaat](https://github.com/ghostty-org/ghostty/blob/v1.3.1/src/renderer/Metal.zig#L204).

### Controle en zelf testen

De oorspronkelijke `CriticallyDampedSpringAnimation` is uit Neovides
versiebestand gehaald en in een tijdelijk Rust-programma uitgevoerd. De GLSL
is gecompileerd en op de lokale OpenGL 4.1-GPU gerenderd. Na de `A`-correctie
kwamen alle 352 combinaties van afgeronde hoekposities overeen: 12 richtingen
× 3 cursorvormen × 8 tijdstippen, plus 8 vormwissels × 8 tijdstippen. De
Rust-veer liep in stappen van 1/120 s; de sprongen liepen op tot 3000 pixels.
De referentie kreeg dezelfde cursorafmetingen als de shader. De
vergelijking gebruikt dezelfde verstreken tijd; de twee apps kunnen hun
eerste animatieframe op een ander moment tonen.

Daarnaast zijn 44 beelden gecontroleerd op geldige kleurwaarden, behoud van
cursorpixels en alpha, `A`/`I`, brede cursors, typen en vormwissels zonder
verplaatsing. De `A`- en `I`-proeven combineerden een sprong van 300 pixels
met de overgang van blok naar balk. Beide tekenden een trail; typen en alleen
van vorm wisselen niet. De eerdere controles op verborgen cursors,
focuswissels en samenvallende hoeken waren eveneens geslaagd.
Dit controleert de GLSL en geometrie; Ghostty's omzetting naar Metal en
Skia's precieze randdekking zijn hiermee niet visueel gelijk bewezen.

Herlaad Ghostty via **Reload Configuration** in het menu. Vergelijk met
Neovide: één `j` of `k`, `A` vanaf het begin van een lange regel, `I` vanaf het
einde, een grote horizontale sprong, diagonale verplaatsingen
en daarna ingedrukte `j/k`. Controleer in insert mode dat typen geen tweede
balkcursor oplevert. Grote losse sprongen zijn de bruikbaarste vergelijking
voor de hoekvorm; herhaalde sprongen tonen de hierboven beschreven beperking.

`custom-shader-animation = true` blijft staan. De eerdere meting van
13 september vergeleek `always` met `true` in een onbeheerd venster:
11% van één CPU-core tegenover 0,0%, over acht samples. Die CPU-meting is
niet herhaald voor deze shaderwijziging.

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

foot blijft een Wayland-optie, geen Mac-migratieplan. Over Ghostty stond hier
dat een cursor trail een externe GLSL-shader zou vergen en dat die toch niet
gebruikt zou worden. Het eerste klopt, het tweede niet: Ghostty is op
13 september de terminal geworden en juist die shader komt het dichtst bij
Neovide — zie de uitkomst bovenaan.

Het onderzoek van 10 september is gecontroleerd tegen lokale configuratie,
upstreamdocumentatie, Ghostty 1.3.1- en kitty 0.48.2-broncode en historische
meldingen — toen zonder installatie. Kitty is daarna wél geïnstalleerd en
visueel beoordeeld; Ghostty en foot niet. De online docs en foot `master`
kunnen veranderen: verifieer bij installatie de meegeleverde handleiding.
