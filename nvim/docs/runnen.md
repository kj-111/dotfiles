# Runnen: C, Java, Rust en Python

compileren.md gaat over `:make`, shell.md over hoe je aan een shell komt.
Dit is wat je erin typt.

## C

### Los bestand

In een C-buffer zonder Makefile zet de ftplugin `:make` op make's impliciete
regel voor het huidige bestand. Opslaan, bouwen en daarna in `CTRL-F` draaien:

```vim
:w
:make
```

```sh
./programma
```

De uitvoerbare file krijgt dezelfde naam als de bron zonder `.c`:
`programma.c` wordt `programma`. `./` is nodig omdat de huidige map niet in
`PATH` staat. Compilerfouten landen in de quickfix en loop je af met `]q` en
`[q`.

### Project met Makefile

Zodra er hogerop een `Makefile` staat, blijft `makeprg` gewoon `make` en
bepaalt die Makefile wat `:make` bouwt. Daarna start je in de terminal de
binary die het gekozen target oplevert; de naam daarvan is projectspecifiek.

## Java

Het vertrekpunt: bij een jinit-project hoef je meestal niet te bouwen. Jdtls
compileert bij elke `:w` incrementeel, naar de map die in de meegeleverde
`.classpath` staat — `out/` bij een plain project, `target/classes` bij een
maven-project (lsp.md). Dus `CTRL-F` en meteen runnen.

### Plain project

```
java -cp out Main
```

`-cp` zegt waar de JVM klassen zoekt: "A ":"-separated list of directories,
JAR archives, and ZIP archives to search for class files" (`java --help`).
Je geeft de klassenaam, niet het bestand — dus `Main`, niet `out/Main.class`.

Zit de klasse in een package, dan gebruik je de volledige naam en blijft
`-cp` de wortel eronder:

```
java -cp out be.odila.Hulp
```

Alles achter de klassenaam is voor jouw programma, niet voor de JVM:
`java -cp out Main een twee` geeft `args.length == 2`.

Vraagt je programma om invoer (Scanner, `readLine`), dan moet het in een
echte terminal draaien — `:!` heeft geen invoerkanaal (shell.md).

### Los bestand, zonder project

```
java Main.java
```

Sinds Java 22 compileert dat de klassen ernaast mee: een `Main.java` die
`be/odila/Hulp.java` importeert draait zo, zonder `javac` en zonder `out/`.
Bedoeld om "a source-file program" uit te voeren (`java --help`); er blijft
niets op schijf achter. Voor een oefening van tien regels de kortste weg —
in een project wil je de gecompileerde vorm, want die staat er al.

### Maven

Ook hier heeft jdtls al gecompileerd:

```
java -cp target/classes Main
```

Maven zelf erbij halen is alleen nodig als je meer wilt dan draaien. De
fasen lopen op, elke bevat de vorige:

```
mvn compile     alleen src/main/java
mvn test        compileert de tests erbij en draait ze
mvn verify      inclusief integratietests
```

`:make` doet `mvn --batch-mode compile` (java.lua) en bouwt dus alleen; wil
je de tests, dan plakt `:make test` dat doel erachter en landen faalende
tests in de quickfix (quickfix.md).

Er bestaat ook `mvn exec:java -Dexec.mainClass=Main`, en dat werkt zonder de
plugin in je pom te zetten. Alleen is het geen winst: gemeten op het
jinit-template start `java -cp target/classes Main` in 33 ms en
`mvn exec:java` in 830 ms, omdat Maven eerst zijn hele projectmodel opbouwt
om daarna dezelfde JVM te starten.

Zodra je een dependency hebt die je programma tijdens het draaien nodig
heeft, is `target/classes` alleen niet genoeg — de jars liggen in `~/.m2`.
Die lijst kun je laten uitrekenen:

```
mvn -q dependency:build-classpath -Dmdep.outputFile=cp.txt
java -cp target/classes:$(cat cp.txt) Main
```

In het jinit-maven-template speelt dat nog niet: daar staat alleen JUnit,
met `<scope>test</scope>`, dus je main-code heeft geen jars nodig.

### Welke wanneer

| situatie                              | commando                                     |
| ------------------------------------- | -------------------------------------------- |
| jinit plain, na `:w`                  | `java -cp out Main`                          |
| jinit maven, na `:w`                  | `java -cp target/classes Main`               |
| los oefenbestand                      | `java Main.java`                             |
| tests draaien                         | `mvn test`, of `:make test` voor de quickfix |
| zeker weten dat het buiten nvim bouwt | `mvn clean verify`                           |

De diepere uitleg — bytecode, JVM, classpath, de Maven-lifecycle — staat in
`~/academia/uni/java/notes/md/java-tooling.md`.

## Rust

Cargo bouwt én draait in één commando: "Run a binary or example of the local
package" (`cargo run --help`). Hij zoekt zelf omhoog naar `Cargo.toml`, dus
waar je in het project staat maakt niet uit.

Dat werkt ook zonder de terminal. In een Rust-buffer is `makeprg` gewoon
`cargo $*` (compileren.md), dus `:make run` voert hetzelfde `cargo run` uit —
alles achter `:make` gaat rechtstreeks naar cargo.

### Cargo-project

```
cargo run
```

Heeft het project meer dan één binary, dan moet je kiezen — "Name of the bin
target to run":

```
cargo run --bin tweede
```

Elke extra binary staat als eigen `[[bin]]` in `Cargo.toml`. Heeft het project
er maar één, zoals `projects/rust/code`, dan volstaat kaal `cargo run`.

Argumenten voor je eigen programma komen achter `--`; zonder die scheiding
leest cargo ze als zijn eigen vlaggen. In de help heet dat `[ARGS]...`,
"Arguments for the binary or example to run":

```
cargo run -- een twee
```

Is er niets veranderd, dan kun je de binary ook rechtstreeks starten. Hij
staat in `target/debug/` onder de `name` uit `Cargo.toml` — voor
`projects/rust/code` dus `rust-oefeningen`, niet `main`:

```
./target/debug/rust-oefeningen
```

Dat scheelt: gemeten op dat project 21 ms rechtstreeks tegen 178–199 ms via
`cargo run`, allebei op een al gebouwd project. Die 180 ms is niet voor niets
— cargo controleert eerst of er iets gewijzigd is en hercompileert zo nodig.
Precies daarom is `cargo run` het normale commando en is de binary rechtstreeks
alleen handig als je zeker weet dat er niets veranderd is.

`--release` bouwt de geoptimaliseerde versie, die dan in `target/release/`
terechtkomt.

### :make run of de terminal

Het verschil zit niet in wat er draait, maar in waar de in- en uitvoer heen
gaat. Bij `:make run` komt de output van je programma in de quickfix: een
`println!` levert daar gewoon een regel op.

Alleen heeft `:make` geen invoerkanaal, en dat is geen detail. Een programma
dat op `read_line` wacht krijgt meteen einde-bestand: gemeten leverde dat
`gelezen: 0 bytes -> ""` op, zonder foutmelding en zonder dat je iets kunt
intypen. Je prompt staat er wel, je antwoord komt er nooit.

Dus `:make run` als je alleen output wilt zien en in de buffer wilt blijven;
`CTRL-F` en `cargo run` zodra je programma iets terugvraagt (shell.md). Dat
is dezelfde afweging als bij Java.

### Tests

```
cargo test
```

"Execute all unit and integration tests and build examples of a local package"
(`cargo test --help`). Een naam erachter filtert; de rest wordt geteld als
"filtered out":

```
cargo test dubbel_werkt
```

Wat je test met `println!` uitprint, slikt de testrunner standaard in. Met
`--nocapture` zie je het wel — en ook hier scheidt `--` jouw vlaggen van die
van cargo:

```
cargo test -- --nocapture
```

Via `:make test` werkt het ook, maar met een beperking die het waard is te
weten. Faalt een test, dan komt de output wel in de quickfix maar zonder
regelnummers: gemeten 16 regels, geen enkele aanspringbaar, ook al staat de
panic-locatie (`src/main.rs:18:9`) gewoon in de tekst. De cargo-errorformat
herkent compilerfouten, geen testpanics. Ter vergelijking: bij een echte
typefout levert `:make check` wél een bruikbare regel op —
`src/main.rs:2:18 mismatched types`, direct aanspringbaar met `]q`.

Dus: `:make check` voor compilerfouten, `cargo test` in de terminal voor
faalende tests, waar je de panic-locatie leest en er zelf heen springt.

### Los bestand

Zoals bij C: compileren geeft een uitvoerbare file met dezelfde naam zonder
extensie.

```sh
rustc los.rs
./los
```

Eén verschil met cargo: kale `rustc` staat niet op de recentste editie.
`async` faalt dan met `expected identifier`, terwijl hetzelfde bestand met de
vlag wel compileert. `Cargo.toml` regelt dat in een project via `edition`
(2024 in `projects/rust/code`); los geef je het zelf mee:

```sh
rustc --edition=2024 los.rs
```

De keuzes staan in `--edition <2015|2018|2021|2024|future>` (`rustc --help`).

### Welke wanneer

| situatie                   | commando                               |
| -------------------------- | -------------------------------------- |
| project, gewoon draaien    | `cargo run`                            |
| project met meer binaries  | `cargo run --bin naam`                 |
| argumenten meegeven        | `cargo run -- een twee`                |
| niets veranderd, snelst    | `./target/debug/naam`                  |
| tests                      | `cargo test`, of `cargo test naam`     |
| print uit tests zien       | `cargo test -- --nocapture`            |
| draaien zonder de terminal | `:make run`, output in de quickfix     |
| programma vraagt om invoer | `CTRL-F`, dan `cargo run`              |
| compilerfouten in quickfix | `:make check` (compileren.md)          |
| los oefenbestand           | `rustc --edition=2024 los.rs && ./los` |

## Python

### Losse expressies in een split

Om snel iets uit te proberen blijft er meestal een terminalsplit naast de
code open. Open een horizontale split met `:split +term` — of verticaal met
`:vs +term` — en start daarin `python3`:

```python
>>> type('a')
<class 'str'>
```

Zo kun je kleine expressies, imports en API-gedrag controleren zonder eerst
een tijdelijk script te schrijven. `CTRL-D` sluit de Python-prompt en brengt
je terug naar de shell in dezelfde split.

### Bestand laden in de interactieve prompt

Met `-i` voert Python eerst het bestand uit en blijft daarna in de REPL:
"inspect interactively after running script" (`python3 --help`). Klassen,
functies en variabelen uit het bestand zijn dan meteen beschikbaar.

Hiervoor open je met `CTRL-F` de zwevende terminal en voer je daar het
commando uit:

```sh
python3 -i mijn_bestand.py
```

Daarna kun je direct een object maken en ermee experimenteren:

```python
>>> object = MijnKlasse(argumenten)
>>> object.methode()
```

De losse `python3`-prompt blijft meestal in een terminalsplit naast de code;
de float is handig wanneer je het huidige bestand tijdelijk met `-i` wilt
laden.

De interactieve geschiedenis wordt automatisch bewaard in
`~/.python_history`. Daardoor zijn commando's uit een vorige REPL-sessie met
`CTRL-P` of de pijltjestoets omhoog opnieuw beschikbaar. `PYTHON_HISTORY` kan
het pad veranderen, maar zonder die variabele gebruikt Python dit bestand in
je home-map.

Python voert daarbij ook alle andere code op top-level uit. Code die alleen
bij normaal starten hoort zet je daarom onder
`if __name__ == '__main__':`. Wil je uitsluitend de klasse importeren:

```
python3 -i -c "from mijn_bestand import MijnKlasse"
```
