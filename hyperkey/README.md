# Hyperkey

Keyboard: QWERTY ISO

- left option → Hyper (⌃⌥⌘) — zonder Shift, alleen op keypress + Click
- caps lock → left control — dubbel ingesteld: zowel in Hyperkey als in macOS zelf

## macOS-toetsenbordinstellingen (System Settings → Keyboard)

- F-toetsen als standaardfunctietoetsen: aan (Function Keys)

- Globe-toets → Do Nothing

- Toetsenbordverlichting: automatisch aanpassen in weinig licht uit, helderheid laag,
  en niet doven bij inactiviteit (Never)

- Keyboard navigation aan: Tab loopt in dialogen ook door knoppen, spatie drukt —
  geldt ook in browsers, waar Tab dan door links gaat

- Alle toetscombinaties uit (Windows-tiling, Keyboard-focus, Input Sources, Presenter
  Overlay, Services, Accessibility), behalve: screenshots (`⇧⌘3/4/5`) en Spotlight (`⌘Space`)

- App Shortcuts: Finder Redo/Undo/Cut "gedisabled" door ze op bewust onbruikbare chords
  te mappen (`^⌥⇧⌘Z` / `^⌥⇧⌘A` / `^⌥⇧⌘E`)

- App Shortcuts: Greenfoot "Recompile Scenario" op `⌘K` gezet

- Mission Control/Spaces: alles uit, incl. `^←/→` (geverifieerd via `symbolichotkeys`) —
  dus geen conflict met woord-springen in Windows-keymaps

## Overige instellingen (uitgelezen via `defaults`)

- Press-and-hold uit (`ApplePressAndHoldEnabled 0`): toets ingedrukt houden = herhalen
- Toetsherhaling: repeat rate helemaal op Fast (`KeyRepeat 2`), delay until repeat
  net rechts van het midden (`InitialKeyRepeat 30`)
- Tekstcorrectie: spellingcorrectie uit; auto-hoofdletters en dubbele-spatie-punt aan
