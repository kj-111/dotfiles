# tools

Eigen CLI-tools, versioneerbaar in deze dotfiles-repo. Elke tool leeft in zijn
eigen map (`~/.config/tools/<naam>/`) samen met zijn templates, config en
README. `~/.local/bin` is de command-laag: die bevat alleen symlinks naar de
scripts hier, en staat via `zshrc` in `PATH`.

```
~/.config/tools/<naam>/<script>   # het echte script + bijbehorende bestanden
~/.local/bin/<naam>               # symlink → het script hierboven
```

Voordelen van deze opzet:

- Script en bijbehorende data (templates, config) blijven samen en worden
  mee-geversioned.
- `~/.local/bin` zelf hoeft niet in de repo; het is puur een dunne laag van
  symlinks.
- Scripts kunnen hun eigen map terugvinden door de symlink te resolven
  (zie `jinit` voor het patroon) en zo hun templates naast zich vinden.

## Huidige tools

| Command             | Tool                     | Omschrijving                                                       |
| ------------------- | ------------------------ | ------------------------------------------------------------------ |
| `cinit`             | [cinit](cinit/README.md) | Generator voor minimale C23-projecten met Makefile                 |
| `jinit`             | [jinit](jinit/README.md) | Generator voor Java-projecten (plain / Maven / JavaFX / Greenfoot) |
| `dash`, `dashboard` | dashboard                | Repo-dashboard (twee entrypoints, lokaal)                          |
| `ultrabackup`       | ultrabackup              | Backup-tool (lokaal)                                               |

`cinit` en `jinit` zijn in git getrackt; de rest is lokaal (zie `.gitignore`:
`tools/*` met uitzonderingen voor beide). Daarnaast staat er één echte
binary in `~/.local/bin` die geen symlink is: `ffmpeg` (te groot voor de
repo, handmatig geïnstalleerd).

## Nieuwe tool toevoegen

```sh
mkdir ~/.config/tools/mytool
# schrijf ~/.config/tools/mytool/mytool, maak executable
chmod +x ~/.config/tools/mytool/mytool
ln -s ~/.config/tools/mytool/mytool ~/.local/bin/mytool
```

Conventies:

- De map, het script en de symlink heten alle drie hetzelfde.
- Elke tool krijgt een eigen `README.md` in zijn map.
- Scripts die bestanden naast zich nodig hebben resolven eerst hun symlink
  naar het echte pad (POSIX-patroon: `readlink`-loop, zie `jinit`).

## Onderhoud

Tool verwijderd? Ruim dan ook de symlink op. Dode symlinks vinden:

```sh
find ~/.local/bin -type l ! -exec test -e {} \; -print
```

Symlinks controleren:

```sh
ls -la ~/.local/bin
```
