# jinit

Generator voor Java projecten met vier modi: plain, Maven, JavaFX en Greenfoot.

## Vereisten

| Tool | Versie | Opmerking |
|------|--------|-----------|
| Java (Temurin) | 25 | `java -version` |
| Maven | 3.9+ | Alleen voor `--maven` en `--javafx` modi |
| Perl | 5.x | Voor template variable substitutie |

## Installatie

Zorg dat `jinit` in je `PATH` staat. Bijvoorbeeld via een symlink:

```sh
ln -s "$HOME/.config/tools/jinit/jinit" "$HOME/.local/bin/jinit"
```

In deze dotfiles setup is `~/.local/bin` de command-laag:

```sh
~/.local/bin/jinit
```

## Gebruik

### Plain Java (geen build tool)

```sh
jinit demo
jinit ~/projects/scratch/demo
```

Maakt een minimale setup met `.project`, `.classpath`, `.java-root` en `src/Main.java`.
Geschikt voor `java src/Main.java` en jdtls/IntelliJ.

### Maven met JUnit 6

```sh
jinit --maven demo
jinit -m ~/projects/scratch/demo
```

Maakt een Maven project met:
- `pom.xml` (Java 25, JUnit 6.1.2)
- `src/main/java/Main.java`
- `src/test/java/MainTest.java` met gangbare JUnit 6 assertions
- `.project`, `.classpath` en `.settings/` voor jdtls/Eclipse tooling

```sh
cd demo
mvn test
```

### JavaFX met Maven en JUnit 6

```sh
jinit --javafx demo
jinit -f ~/projects/scratch/demo
```

Zelfde opzet als de Maven-modus, plus:
- `javafx-controls` dependency (JavaFX 26.0.1, natives via Maven classifier)
- `javafx-maven-plugin` zodat `mvn javafx:run` werkt
- `src/main/java/Main.java` als `Application` met een minimale Scene

```sh
cd demo
mvn javafx:run
```

### Greenfoot-scenario

```sh
jinit --greenfoot knikkerbaan
jinit -g ~/academia/projects/knikkerbaan
```

Maakt een platte Greenfoot-projectmap — de enige vorm die Greenfoot kent
(zie uni/java/notes/greenfoot.pdf A6): `project.greenfoot`, `Wereld.java`
(extends World) en `Speler.java` (extends Actor) als startskelet, lege
`images/` en `sounds/`, `lib/greenfoot.jar` als symlink naar de jar in
/Applications/Greenfoot.app, plus de gewone tooling-laag (`.classpath` met
src in de root, `.project`, `.java-root`, `.settings/`). Vereist dus een
geïnstalleerde Greenfoot (brew install --cask greenfoot).

```sh
cd knikkerbaan
open -a Greenfoot .                            # draaien en compileren
javac -cp lib/greenfoot.jar -d out *.java      # snelle syntaxcheck
```

## CLI

```bash
Usage: jinit [OPTIONS] <project-name-or-path>

Options:
  -m, --maven      Create a Maven project with JUnit 6
  -f, --javafx     Create a JavaFX Maven project with JUnit 6
  -g, --greenfoot  Create a Greenfoot scenario
  -h, --help       Show this help message
```

## Templates

### Projectinstellingen (`.settings/`)

Alle vier de templates delen dezelfde `org.eclipse.jdt.core.prefs`: die
regels zijn byte-voor-byte gelijk, met per template hooguit één eigen regel
eronder (greenfoot een builder-filter, maven/javafx annotation processing
uit). Zo krijgt dezelfde code overal dezelfde behandeling, ongeacht met
welke vlag je jinit aanriep.

Leidraad: het project zegt het zelf, de editor niet. Wat hier niet staat
vult jdtls in met zijn eigen defaults, en die kunnen bij een update stil
verschuiven — precies de fout waardoor javadoc ooit op 84 tekens afbrak.
Dat geldt net zo goed voor een andere editor: in nvim komen inspringing en
de newline op het einde toevallig goed, in IntelliJ of Eclipse niet.

Regelbreedte, op 100 — goed voor de laptop en split screen (twee bestanden
naast elkaar zonder horizontaal scrollen), en dezelfde marge als de
cursuscode van prog1:

- `formatter.lineSplit=100` — code
- `formatter.comment.line_length=100` — commentaar en javadoc hebben een
  eigen breedte; zonder deze brak javadoc af rond 84 terwijl code tot 100 mocht
- `formatter.comment.count_line_length_from_starting_position=false` —
  tel die 100 vanaf kolom 0, niet vanaf waar het commentaar begint (anders
  komt de inspringing er nog bovenop)

Opmaak die niet van de editor mag afhangen:

- `formatter.tabulation.char=space` + `tabulation.size=4` +
  `indentation.size=4` — vier spaties, zoals de cursuscode; de
  Eclipse-default is tabs
- `formatter.insert_new_line_at_end_of_file_if_missing=insert` — POSIX-einde,
  scheelt "\ No newline at end of file" in elke diff

Verder levert elke template `org.eclipse.core.resources.prefs` met
`encoding=UTF-8`, zodat een `é` of `ë` niet afhangt van de standaard-charset
van de JVM die jdtls draait.

### Plain (`templates/`)

```bash
templates/
├── .classpath
├── .gitignore
├── .java-root
├── .project
├── .settings/
└── src/
    └── Main.java
```

### Maven (`templates-maven/`)

```bash
templates-maven/
├── .classpath
├── .gitignore
├── .project
├── .settings/
├── pom.xml
└── src/
    ├── main/java/
    │   └── Main.java
    └── test/java/
        └── MainTest.java
```

### JavaFX (`templates-javafx/`)

Zelfde structuur als `templates-maven/`, maar `Main.java` is een JavaFX
`Application` en de `pom.xml` bevat de JavaFX dependency en run-plugin.

### Greenfoot (`templates-greenfoot/`)

```bash
templates-greenfoot/
├── .classpath          # src in de projectroot zelf, lib/greenfoot.jar
├── .gitignore          # alleen buildrommel: out/, *.class, *.ctxt
├── .java-root
├── .project
├── .settings/
├── project.greenfoot   # minimaal; Greenfoot vult hem zelf aan
├── Wereld.java         # extends World, plaatst één Speler
├── Speler.java         # extends Actor
├── images/             # (.gitkeep: git trackt geen lege mappen)
├── sounds/
└── lib/
    └── greenfoot.jar   # symlink naar /Applications/Greenfoot.app/…
```

Plat zoals Greenfoot het eist: de `.java`-bestanden in de projectroot, geen
`src/`. De symlink reist als symlink mee bij het kopiëren.

## Structuur Conventies

### Plain: `src/`
Geen build tool, dus alles zit direct onder `src/`.
Je runt code met `java src/Main.java`.
Eenvoudig, snel, geen overhead.

### Greenfoot: plat
Greenfoot kent geen bronmappen of packages: de `.java`-bestanden staan in de
projectroot, naast `project.greenfoot`, `images/` en `sounds/`. Draaien doe je
in Greenfoot zelf (`open -a Greenfoot .`); `out/` vangt de bytecode van de
tooling: de `javac`-syntaxcheck én de Eclipse-compiler in jdtls, die
voortdurend compileert (dáár komen de diagnostics vandaan) en zijn uitvoer
ergens kwijt moet. `resourceCopyExclusionFilter=*` in `.settings/` houdt
out/ beperkt tot `.class`-bestanden. Bewust gescheiden van Greenfoots eigen
platte `.class`-bestanden: Eclipse schrijft ook bij compileerfouten een
`.class`, en die mag Greenfoot nooit te pakken krijgen.

`greenfoot-src.zip` (hier in de jinit-map) bevat de API-bronnen van Greenfoot
3.9.0; de `.classpath` verwijst ernaar via `sourcepath`, waardoor K in nvim de
volledige javadoc toont en CTRL-] in de echte broncode landt. Bij een
Greenfoot-update: bronnen opnieuw ophalen van de GREENFOOT-RELEASE-tag op
github.com/k-pet-group/BlueJ-Greenfoot (map greenfoot/src/main/java/greenfoot)
en opnieuw inpakken.

Workflow met een externe editor: na wijzigingen in nvim moet je in Greenfoot
zelf op "Recompile scenario" klikken — Greenfoots automatische compilatie
geldt alleen voor zijn eigen ingebouwde editor, externe edits worden wel
gedetecteerd maar niet vanzelf gecompileerd. Eén klik per testrondje.

### Maven: `src/main/java/` + `src/test/java/`
Maven vereist deze conventie. Het scheidt productiecode van testcode:

```bash
src/
├── main/
│   ├── java/      # productiecode → target/classes
│   └── resources/ # config, props
└── test/
    ├── java/      # testcode → target/test-classes
    └── resources/ # test fixtures
```

Voordelen:
- Test dependencies (JUnit) lekken niet naar je production jar
- `mvn test` compileert en runt tests apart
- IntelliJ herkent het automatisch
- Standaard in de hele Java-ecosysteem

## Afhankelijkheden (Maven / JavaFX)

| Dependency | Versie | Scope | Modus |
|------------|--------|-------|-------|
| junit-jupiter | 6.1.2 | test | maven, javafx |
| javafx-controls | 26.0.1 | compile | javafx |

| Plugin | Versie | Modus |
|--------|--------|-------|
| maven-compiler-plugin | 3.15.0 | maven, javafx |
| maven-surefire-plugin | 3.5.6 | maven, javafx |
| javafx-maven-plugin | 0.0.8 | javafx |

## Versies bumpen

De versies hierboven staan gepind in de templates en verouderen dus. Bij een
bump zijn dit de plekken om aan te passen:

1. `templates-maven/pom.xml` — `junit.version` + plugin-versies
2. `templates-javafx/pom.xml` — zelfde, plus `javafx.version` en `javafx-maven-plugin`
3. De tabellen hierboven in deze README
4. Bij een JUnit major-bump: de "JUnit N" vermeldingen in deze README en in de
   `--help` tekst van het `jinit` script

Nieuwste versie opzoeken — gebruik de `maven-metadata.xml` op repo1
(de search.maven.org API geeft verouderde data):

```sh
curl -s "https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter/maven-metadata.xml" \
  | grep "<version>" | tail -5
```

Let op: `<latest>` kan een beta/milestone zijn (bv. compiler-plugin 4.0.0-beta
voor Maven 4) — pak de nieuwste *stabiele* uit de versielijst. Verifieer daarna
door een vers project te genereren: `mvn test` voor maven/javafx, en voor
javafx ook `mvn javafx:run`.
