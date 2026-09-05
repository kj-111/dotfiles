# Neovide

GUI-client voor dezelfde nvim-config. Starten met `nvide`; aerospace zet het
venster op workspace 3, fullscreen. Installeren via `cask "neovide-app"`.

## Twee configbestanden

`neovide/config.toml` is de app zelf: venster, font, hotkeys. Die leest Neovide
voor nvim start, dus alles wat het venster vormt hoort daar.

`nvim/lua/config/neovide.lua` zijn de `vim.g.neovide_*`-instellingen. Het hele
bestand zit achter `if not vim.g.neovide then return end`, dus in de terminal
gebeurt er niets. In init.lua staat de require ná `require('set')`, want
`setup()` overschrijft 'guicursor' met een variant die `Cursor/lCursor` gebruikt.
De balk staat daar bewust op `ver25` tegen `ver35` in set.lua; smaller in de
GUI is een keuze, geen drift.

## Font

Zelfde familie, faces en grootte als `alacritty.toml`, zodat beide er hetzelfde
uitzien. Eerder stond hier Light/Medium om Neovides zwaardere rendering te
compenseren, maar met Monaspace viel dat te dun uit — mede omdat text_gamma en
text_contrast al afdunnen.

Hier wijken de twee wél bewust af, via `[font.features]`. Alacritty shapet niet
(geen harfbuzz, en van CoreText alleen `CTFontGetGlyphsForCharacters`), dus
daar worden `liga` en `calt` nooit toegepast — je ziet Monaspace kaal. Neovide
shapet wel, en is dus de enige plek waar texture healing (`calt`) te zien is.

Dat is een afweging, geen gratis winst. Texture healing kiest de vorm van een
teken op basis van zijn buren, dus zodra je een letter bijtypt kan het teken
ervóór alsnog van variant wisselen. Rustiger spatiëring in stilstaande tekst,
onrustiger beeld tijdens het typen. Ligaturen staan daar los van en blijven uit
met `-liga`.

De rendering staat op Neovides eigen Alacritty-emulatie: "you can use a gamma
of 0.8 and a contrast of 0.1" (neovide.dev/configuration.html). De defaults
zijn 0.0 en 0.5, dus dit dunt de strokes af. Te dun? Die kant op bewegen.

## Wat je niet kunt instellen

Cmd-Q, Cmd-N, Cmd-M, Cmd-H, Opt-Cmd-H en Ctrl-Cmd-F zijn key equivalents van
Neovides native menubalk. AppKit verwerkt die vóór het toetsevent het venster
bereikt, dus nvim ziet ze nooit — een mapping erop kan niets doen. Er is ook
geen configsleutel voor: de struct kent alleen `system-pinned-hotkey`,
`system-switcher-hotkey` en de twee voor native tabs.

Dat is de hele lijst; `src/platform/macos/mod.rs` bouwt geen Close-item, dus
Cmd-W bereikt nvim wél en is gewoon te mappen. Fullscreen zit op Ctrl-Cmd-F,
dus Cmd-F is ook vrij.

Het vangnet is `neovide_confirm_quit`, expliciet aan gezet. Dat is de
gedocumenteerde default, maar Neovides eigen Lua valt terug op
`vim.g.neovide_confirm_quit or false` als de variabele leeg is.

`title-hidden` staat er bewust niet: bij `frame = "none"` gaat Neovide de
`with_decorations(false)`-tak in en wordt de sleutel niet doorgegeven.

Wil je de toets echt dood, dan is het macOS: System Settings → Keyboard →
Shortcuts → App Shortcuts, het menu-item op een onbruikbare chord zetten.
Dezelfde truc als bij Finder (hyperkey/README.md).

## Waarom aerospace op app-name matcht

De regel gebruikt `if.app-name-regex-substring = '(?i)neovide'` en niet
`if.app-id`, terwijl de rest van het bestand wel op app-id matcht. Reden:
start je Neovide via het kale commando, dan is dat `/opt/homebrew/bin/neovide`,
de binary uit de bundel. macOS koppelt dat proces niet aan de `.app` en
aerospace ziet dan:

```
1 | NULL-APP-BUNDLE-ID | neovide
```

Geen bundle-id, dus een regel op app-id vuurt niet. Via de app wél
(`3 | com.neovide.neovide | Neovide`). De regex vangt allebei, want de naam is
`neovide` of `Neovide`.

## Eén instance

Die is er niet. Elke `nvide` geeft een venster erbij. `--reuse-instance` lost
dat niet op: twee keer aanroepen vanaf de CLI geeft gewoon twee processen,
omdat de vlag leunt op macOS' app-registratie die er bij de kale binary niet is.

Wat wel werkt is `open -a Neovide` — macOS activeert dan de draaiende app in
plaats van een tweede te starten. De prijs is dat een bestand openen in een
al draaiende instance niet meer gaat, en dat het kale commando verdwijnt.
Bewust niet gekozen.
