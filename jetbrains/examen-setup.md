# JetBrains examen-setup

> ⚠️ Oefen in een default JetBrains-setup — géén IdeaVim, géén eigen keybinds,
> géén AI-completion. Zo zit het exact zoals op het examen.

Geldt voor PyCharm 2026.2, WebStorm 2026.2 en IntelliJ IDEA 2026.2.
Uitzondering: in IntelliJ is IdeaVim geïnstalleerd (bewuste keuze, 20-08-2026) —
voor examen-oefenen de plugin even uitzetten via Settings → Plugins.

## Praktische routine

- Gebruik tijdens het schooljaar geregeld een uni-computer en doorloop daar kort
  **Learn IDE Features** om de echte Windows-keymap te blijven oefenen.
- Ga op de examendag iets vroeger. Zet de pc op qwerty en doorloop snel enkele
  Learning-stappen om navigatie, completion en run/debug te controleren.
- Shortcut vergeten? `Ctrl+Shift+A` opent **Find Action**.

## De procedure

1. Reset naar default settings: File → Manage IDE Settings → Restore Default
   Settings. De IDE herstart en zet je oude config apart in
   `~/Library/Application Support/JetBrains/<IDE>-backup/<datum>/`.
   Let op: deze reset gooit ook stap 2 en 3 weg, dus doe hem altijd als eerste.

2. Inline completion uit (zoals op het examen): Settings → Editor → General →
   Inline Completion → "Enable inline completion using language models" uitvinken.
   Dit is de echte schakelaar — `disabled_plugins.txt` alleen is niet genoeg,
   want de completion zelf zit in de IDE-kern en niet in een plugin.

3. Keymap op "Windows" zetten: op macOS eerst de plugin XWin Keymap installeren
   (Settings → Plugins → Marketplace), daarna Settings → Keymap → "Windows".
   Dan werken de `Ctrl`-shortcuts uit `jetbrains-windows-shortcuts.md` ook op de
   Mac exact zoals op het examen. In de config heet het schema "Default for XWin".

4. Settings Sync uit: Settings → Settings Sync. Anders trekt de sync je thuis-
   instellingen weer binnen en ben je stap 1 t/m 3 kwijt.

5. Plugins uitzetten via `disabled_plugins.txt` — zie de sectie hieronder.

6. Het "AI Chat"-promovenster zit in de IDE-kern (`llmInstaller`-module) en kan
   niet via plugins uit — verbergen met rechtsklik op het zijbalk-icoon → "Remove
   from Sidebar". Zolang je niet op "Install Plugin" klikt, doet het niets.
   In IntelliJ 2026.2 is AI Assistant (`com.intellij.ml.llm`) niet eens bundled,
   dus daar valt alleen het promovenster weg te klikken.

macOS-toetsenbord (F-toetsen, Caps Lock → Ctrl, ...) staat al goed — zie
`~/.config/hyperkey/README.md`.

`lsp_tutorial.py` is de korte eigen oefening voor completion, documentatie,
navigatie en debuggen.

## Plugins uitzetten (`disabled_plugins.txt`)

Eén plugin-id per regel, in de root van de configmap:
`~/Library/Application Support/JetBrains/<IDE>/disabled_plugins.txt`.
De IDE leest dat bestand alleen bij het opstarten, dus bewerk het met de IDE dicht.

De drie lijsten staan als kopie in deze map (`disabled_plugins-pycharm.txt`,
`-webstorm.txt`, `-intellij.txt`) — de repo trackt de configmap zelf niet.
Uitgezet: AI/ML, VCS en git, Docker, remote development, tasks, diagrams, Qodana,
Grazie, settings sync, taalpakketten en de niet-Windows-keymaps.
In IntelliJ blijven Java, Kotlin, Gradle, Maven, JUnit, JavaFX en de trainer aan;
Spring, Jakarta EE en Database staan er ook nog aan — uitzetten kan alsnog als de
cursus die niet gebruikt.

Twee dingen die goed zijn om te weten:

- Onbekende id's zijn onschadelijk. De IntelliJ-lijst is overgenomen van PyCharm en
  WebStorm, en `com.intellij.ml.llm`, `com.intellij.tasks` en
  `com.intellij.tasks.timeTracking` bestaan niet in IDEA. De IDE negeert ze en
  laat ze staan (gecontroleerd 20-08-2026: het bestand werd bij het afsluiten niet
  herschreven). Ze blijven expres in de lijst als vangnet, mocht zo'n plugin later
  alsnog geïnstalleerd worden.
- Een id in de lijst is nog geen bewijs dat het werkt. Wat telt is de
  `Disabled plugins:`-regel in het log — zie hieronder.

## Verificatie zonder de IDE te openen

Sluit eerst alle IDE's; anders schrijft de IDE bij het afsluiten je wijzigingen over.

```sh
# 1. Draait er nog iets?
pgrep -fl -i 'idea|pycharm|webstorm' | grep -v pgrep

# 2. Komt de live lijst nog overeen met de kopie in deze repo?
cd ~/Library/Application\ Support/JetBrains
for ide in IntelliJIdea2026.2:intellij PyCharm2026.2:pycharm WebStorm2026.2:webstorm; do
  diff "${ide%%:*}/disabled_plugins.txt" ~/.config/jetbrains/disabled_plugins-${ide##*:}.txt \
    && echo "${ide##*:}: identiek"
done

# 3. Staat de inline completion uit? (zie kanttekening hieronder)
cat <IDE>/options/ml.inline.completion.xml

# 4. Welke keymap is actief? Geen keymap.xml = nog de macOS-default.
cat <IDE>/options/keymap.xml

# 5. Wat heeft de IDE bij de laatste start echt uitgezet?
grep -a 'Disabled plugins:' ~/Library/Logs/JetBrains/<IDE>/idea.log | tail -1
```

Check 5 is de enige die de werkelijkheid meet in plaats van de bedoeling: de IDE
logt bij elke start welke plugins hij daadwerkelijk heeft uitgeschakeld.

Kanttekening bij check 3: het vinkje uit stap 2 landt in
`options/ml.inline.completion.xml` als `<component name="MLCompletionState">` met
`completionEnabled` op `false`; ontbreekt het bestand, dan staat completion aan
(default). Dit is afgeleid uit hoe de IDE zijn settings wegschrijft, niet uit
JetBrains-documentatie — die `options/*.xml` zijn interne implementatie en kunnen
per versie veranderen. Gebruik het om snel te screenen, en bevestig in de UI.

## Aangepast buiten deze repo

Deze wijzigingen staan in `~/Library/Application Support/JetBrains/` en worden dus
niet door deze config-repo getrackt: de settings-reset, de keymap-keuze, het
inline-completion-vinkje en de drie `disabled_plugins.txt`-bestanden (kopieën
daarvan staan wel hier).
