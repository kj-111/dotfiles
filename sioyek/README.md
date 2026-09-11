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
