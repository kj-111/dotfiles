# Java Scratch

Generator voor Java scratch projecten met twee modi: plain en Maven.

## Vereisten

| Tool | Versie | Opmerking |
|------|--------|-----------|
| Java (Temurin) | 25 | `java -version` |
| Maven | 3.9+ | Alleen voor `--maven` modus |
| Perl | 5.x | Voor template variable substitutie |

## Installatie

Zorg dat `jinit` in je `PATH` staat. Bijvoorbeeld:

```sh
export PATH="$HOME/.config/java-scratch:$PATH"
```

## Gebruik

### Plain Java (geen build tool)

```sh
jinit demo
jinit ~/projects/scratch/demo
```

Maakt een minimale setup met `.project`, `.classpath`, `.java-root` en `src/Main.java`.
Geschikt voor `java src/Main.java` en jdtls/IntelliJ.

### Maven met JUnit 5

```sh
jinit --maven demo
jinit -m ~/projects/scratch/demo
```

Maakt een Maven project met:
- `pom.xml` (Java 25, JUnit 5.14.2)
- `src/main/java/Main.java`
- `src/test/java/MainTest.java` met gangbare JUnit 5 assertions
- `.project`, `.classpath` en `.settings/` voor jdtls/Eclipse tooling

```sh
cd demo
mvn test
```

## CLI

```bash
Usage: jinit [OPTIONS] <project-name-or-path>

Options:
  -m, --maven    Create a Maven project with JUnit 5
  -h, --help     Show this help message
```

## Templates

### Plain (`templates/`)

```bash
templates/
├── .classpath
├── .gitignore
├── .java-root
├── .project
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

## Structuur Conventies

### Plain: `src/`
Geen build tool, dus alles zit direct onder `src/`.
Je runt code met `java src/Main.java`.
Eenvoudig, snel, geen overhead.

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

## Afhankelijkheden (Maven)

| Dependency | Versie | Scope |
|------------|--------|-------|
| junit-jupiter | 5.14.2 | test |

| Plugin | Versie |
|--------|--------|
| maven-compiler-plugin | 3.15.0 |
| maven-surefire-plugin | 3.5.5 |
