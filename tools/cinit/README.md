# cinit

Maakt een klein C23-project met een overzichtelijke Makefile, automatische
headerdependencies en een aparte buildmap.

## Vereisten

- een C23-compiler via `cc` (of geef `CC=...` mee);
- GNU Make 3.81 of nieuwer;
- Perl voor de projectnaamsubstitutie.

## Gebruik

```sh
cinit demo
cd demo
make run
```

Een volledig pad mag ook:

```sh
cinit ~/academia/projects/c/demo
```

De doelmap mag nog niet bestaan of moet leeg zijn. De projectnaam mag alleen
letters, cijfers, punten, underscores en koppeltekens bevatten, en begint niet
met een punt of koppelteken. Een symbolische link wordt niet als doelmap
geaccepteerd.

## Wat wordt aangemaakt

```text
demo/
├── .gitignore
├── Makefile
└── src/
    └── main.c
```

De binary en objectbestanden komen onder `build/`, die door de meegeleverde
`.gitignore` wordt genegeerd.

## Make-targets

```sh
make                 # bouwen
make run             # bouwen indien nodig en uitvoeren
make run ARGS='a b'  # argumenten doorgeven
make clean           # buildmap verwijderen
```

De standaardflags zijn
`-std=c23 -Wall -Wextra -Wpedantic -g -fsanitize=address,undefined`. Zo krijg
je duidelijke compilerwaarschuwingen, debug-informatie en tijdens het draaien
meldingen voor veel geheugenfouten en undefined behavior. De sanitizerflag
staat via `CFLAGS` ook in de linkstap.

De flags zijn voor één build te vervangen met bijvoorbeeld:

```sh
make CFLAGS='-std=c23 -Wall -Wextra -O2'
```

De Makefile houdt `CPPFLAGS`, `CFLAGS`, `LDFLAGS` en `LDLIBS` apart. Door
`-MMD -MP` en de ingelezen `.d`-bestanden wordt alleen de code herbouwd die
afhangt van een gewijzigd projectheader. `make -j` is veilig voor de
meegeleverde buildregels.

Na een handmatige wijziging van de flags gebruik je `make clean`: Make
vergelijkt tijdstempels en merkt een gewijzigde commandline niet zelf op.
