# Sioyek

PDF-lezer met vim-toetsen, gebruikt voor cursussen en papers.

## Installeren

Download [sioyek3-alpha0](https://github.com/ahrm/sioyek/releases/tag/sioyek3-alpha0).
Dat moet die release zijn: het is de enige met een native ARM64-build voor de
Mac. Nagemeten met `lipo -archs`, en de stabiele releases eronder leveren die
niet.

```sh
# sioyek.app naar /Applications slepen, daarna:
xattr -dr com.apple.quarantine /Applications/sioyek.app
```

Die laatste stap moet echt. De app is adhoc gesigneerd — `Signature=adhoc` en
`TeamIdentifier=not set` volgens `codesign -dv` — dus Gatekeeper weigert hem
zonder. Zelfde situatie als Alacritty (gui-apps.txt).

De `Info.plist` meldt versie 2.0; dat is een fout in de alpha-build, niet de
verkeerde download.

## Annoteren

Selecteer tekst met de muis en druk `h` gevolgd door een letter. Die letter is
het type, en elk type heeft zijn eigen kleur. Er zijn er 26 (`a` tot `z`), maar
vier is genoeg om iets aan te hebben; meer kleuren onthoud je toch niet.

De vier op de homerij staan in `prefs_user.config`, in Nord-kleuren:

| toets | kleur | waarvoor                        |
| ----- | ----- | ------------------------------- |
| `ha`  | geel  | belangrijk, kern van het betoog |
| `hs`  | groen | mee eens, bruikbaar bewijs      |
| `hd`  | blauw | vraag, snap ik niet             |
| `hf`  | rood  | oneens, zwakke plek             |

De andere 22 houden hun standaardkleur. Wil je er meer, zet dan
`highlight_color_<letter>` erbij.

| toets    | doet                                         |
| -------- | -------------------------------------------- |
| `h<ltr>` | markeer de selectie met dat type             |
| `dh`     | verwijder: eerst op de markering klikken     |
| `gh`     | spring naar een markering in dit document    |
| `gH`     | spring naar een markering in álle documenten |
| `gnh`    | volgende markering; `gNh` de vorige          |
| `b`      | bookmark met een tekstbeschrijving           |
| `m<ltr>` | mark zetten; `` `<ltr> `` springt erheen     |
| `<f1>`   | markeringen tijdelijk verbergen              |

Marks zijn losse posities met een letter, bookmarks hetzelfde maar met tekst
erbij. Portals (`p`, dan naar de doelplek en weer `p`) leggen een tweezijdige
link, handig tussen een figuur en de tekst die ernaar verwijst.

## Markeringen naar buiten krijgen

Ze staan in `shared.db`, dus geen enkele andere lezer ziet ze. Twee commando's
halen ze eruit, allebei zonder standaardtoets — tik `:` en dan de naam:

- `embed_annotations` schrijft markeringen en bookmarks in een nieuwe pdf,
  zodat ze wél zichtbaar zijn in Preview of een browser. Volgens sioyeks eigen
  `keys.config`: "Embed the annotations (highlights and bookmarks) into a new
  PDF file so they are visible to other PDF readers".
- `export` schrijft alles naar json; `import` leest het terug. Dat is de weg
  voor een verhuizing of een backup los van de database.

## Waar wat staat

`prefs_user.config` en `keys_user.config` staan hier en worden vanaf dit pad
gelezen, dus daar hoeft niets voor gesymlinkt te worden.

De databases zijn wél gesymlinkt, zodat ze bij de documenten leven in plaats
van in Library:

```sh
mkdir -p ~/academia/.sioyek
ln -sf ~/academia/.sioyek/local.db  ~/Library/Application\ Support/sioyek/local.db
ln -sf ~/academia/.sioyek/shared.db ~/Library/Application\ Support/sioyek/shared.db
```

`local.db` bewaart je leesposities en vensterstaat, `shared.db` je highlights,
bookmarks en links. Die laatste is het waardevolst: hij overleeft zo een
herinstallatie en gaat mee in de backup van `~/academia`.

De rest blijft in `~/Library/Application Support/sioyek/`: `auto.config` (door
sioyek zelf geschreven) en `last_document_path.txt`.

Controleren of het werkt — een geldige symlink zegt nog niet dat sioyek er
doorheen schrijft, dus kijk ook of de tabellen vollopen:

```sh
ls -l ~/Library/Application\ Support/sioyek/*.db
sqlite3 ~/academia/.sioyek/shared.db 'select count(*) from highlights'
```
