# Neovide

GUI-client voor dezelfde nvim-config. Starten met `nvide`; aerospace zet het
venster op workspace 1, fullscreen. Installeren via `cask "neovide-app"`.

## Twee configbestanden

`neovide/config.toml` is de app zelf: venster, font, hotkeys. Die leest Neovide
voor nvim start, dus alles wat het venster vormt hoort daar.

`nvim/lua/config/neovide.lua` zijn de `vim.g.neovide_*`-instellingen. Het hele
bestand zit achter `if not vim.g.neovide then return end`, dus in de terminal
gebeurt er niets. In init.lua staat de require ná `require('set')`, want
`setup()` overschrijft 'guicursor' met een variant die `Cursor/lCursor` gebruikt.
De cursorvormen volgen set.lua: blok in Normal en `hor20` in Replace.
In Insert/terminal is de balk bewust iets smaller: `ver30` in plaats van `ver35`.
De uiteindelijke pixels blijven afhankelijk van de renderer.

`Cmd-K` / `Cmd-J` vergroten/verkleinen de GUI-schaal, begrensd op 0.5–2.0.
`Cmd-0` zet die terug op 1.0, dus de ingestelde fontgrootte van 15.5.
Deze toetsen werken in Normal, Insert, Visual, command-line en terminal-mode.
Cursor-, scroll- en vensteranimaties blijven bewust op Neovides defaults.

`Cmd-C` kopieert de Visual-selectie naar het macOS-clipboard. `Cmd-V` plakt
in Normal, Insert, Visual, command-line en terminal-mode via `nvim_paste()`;
de tekst wordt niet als toetsen of mappings uitgevoerd. `clipboard` blijft
ongewijzigd: `y`/`p` en de gewone registers volgen nog steeds Vim.

## Font

Zelfde familie, faces en grootte als `ghostty/config`, zodat editor en terminal
er hetzelfde uitzien. Eerder stond hier Light/Medium om
Neovides zwaardere rendering te compenseren, maar met Monaspace viel dat te dun
uit — mede omdat text_gamma en text_contrast al afdunnen.

In `[font.features]` staat texture healing (`calt`) aan, net als in
`ghostty/config`. Dat kan alleen in een programma dat shapet; Alacritty deed dat
niet, en toonde Monaspace dus altijd kaal. In kitty oogde de `m` er vreemd van
en stond het uit, in Ghostty niet (terminal-weergave.md).

Dat is een afweging, geen gratis winst. Texture healing kiest de vorm van een
teken op basis van zijn buren, dus zodra je een letter bijtypt kan het teken
ervóór alsnog van variant wisselen. Rustiger spatiëring in stilstaande tekst,
onrustiger beeld tijdens het typen. Ligaturen staan daar los van en blijven uit
met `-liga`.

De rendering staat op Neovides eigen Alacritty-emulatie: "you can use a gamma
of 0.8 and a contrast of 0.1" (neovide.dev/configuration.html). De defaults
zijn 0.0 en 0.5, dus dit dunt de strokes af. Te dun? Die kant op bewegen.

## Ongebruikte native menutoetsen uit

De gewenste Cmd-toetsen zijn `J`, `K`, `0`, `C` en `V`. De native shortcuts
voor nieuw venster, afsluiten, verbergen, minimaliseren, fullscreen en Editors
zijn via macOS-appvoorkeuren uitgeschakeld. De menu-items blijven bruikbaar;
`neovide_confirm_quit` beschermt bij onopgeslagen wijzigingen. De globale
activation-hotkeys en native tabnavigatie staan uit in `neovide/config.toml`.

Neovide 0.16.2 heeft voor deze menutoetsen nog geen eigen configopties. AppKit
handelt ze vóór gewone Neovim-input af; alleen Lua-mappings volstaan dus niet.
De online docs beschrijven inmiddels meer `system-*-hotkey`-opties, maar die
worden nog niet door deze versie ondersteund.

Eenmalig op een nieuwe Mac uitvoeren, daarna Neovide volledig herstarten:

```sh
for domain in com.neovide.neovide neovide; do
  defaults write "$domain" NSUserKeyEquivalents -dict-add \
    'New Window' '"\U0000"' \
    'Quit Neovide' '"\U0000"' 'Quit neovide' '"\U0000"' \
    'Hide Neovide' '"\U0000"' 'Hide neovide' '"\U0000"' \
    'Hide Others' '"\U0000"' \
    'Minimize' '"\U0000"' 'Minimize All' '"\U0000"' \
    'Enter Full Screen' '"\U0000"' 'Exit Full Screen' '"\U0000"' \
    'Editors' '"\U0000"'
done
```

Dit koppelt de menu-items aan NUL, geen typbare toets. Een lege string schakelt
de oorspronkelijke shortcut niet uit. Beide domeinen dekken de `.app` en de
kale `nvide`-start; de twee schrijfwijzen dekken de bijbehorende menutitels.
Andere apps en globale macOS-sneltoetsen veranderen niet. Deze voorkeuren staan
in macOS, dus niet automatisch in een clone van `.config`.

Terug naar de standaardmenutoetsen: `defaults delete com.neovide.neovide
NSUserKeyEquivalents` en `defaults delete neovide NSUserKeyEquivalents`, gevolgd
door een herstart. Dat verwijdert alle shortcut-overrides in die twee domeinen.

### Later: vervangen door native Neovide-opties

[PR #3481](https://github.com/neovide/neovide/pull/3481) voegde op 22 april 2026
native menu-shortcutinstellingen toe. Deze ontbreken nog in 0.16.2. Zodra een
stabiele release ze ondersteunt, hebben deze opties in `neovide/config.toml`
de voorkeur boven de macOS-overrides:

```toml
system-new-window-hotkey = false
system-quit-hotkey = false
system-hide-hotkey = false
system-hide-others-hotkey = false
system-minimize-hotkey = false
system-fullscreen-hotkey = false
system-show-all-tabs-hotkey = false
```

Controleer bij de upgrade eerst de ondersteuning in die release; de online docs
kunnen vooruitlopen. Verwijder daarna de hierboven ingestelde macOS-overrides,
herstart Neovide volledig en test de uitgeschakelde toetsen én `Cmd-J/K/0/C/V`.
Alleen hiervoor geen ontwikkelversie of extra keyboard-remapper installeren.

De huidige overrides zijn met AppKit getest, maar nog niet end-to-end in een
herstarte Neovide. De PR meldt dat macOS App Shortcuts niet bij iedereen werken;
controleer dus het echte gedrag na herstart.

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
(`1 | com.neovide.neovide | Neovide`). De regex vangt allebei, want de naam is
`neovide` of `Neovide`.

## Eén instance

Die is er niet. Elke `nvide` geeft een venster erbij. `--reuse-instance` lost
dat niet op: twee keer aanroepen vanaf de CLI geeft gewoon twee processen,
omdat de vlag leunt op macOS' app-registratie die er bij de kale binary niet is.

Wat wel werkt is `open -a Neovide` — macOS activeert dan de draaiende app in
plaats van een tweede te starten. De prijs is dat een bestand openen in een
al draaiende instance niet meer gaat, en dat het kale commando verdwijnt.
Bewust niet gekozen.
