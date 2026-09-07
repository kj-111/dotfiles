# Tools: waar de binaries vandaan komen

De meeste taalservers en formatters zijn gewone brew-formules. Clangd komt mee
met de Xcode Command Line Tools (`/usr/bin/clangd`); Rust gebruikt de officiële
rustup-toolchain. Nvim heeft geen eigen installer nodig: alle configs vinden hun
binaries via je gewone PATH — `lsp/*.lua` en conform zoeken op naam.

## De volledige lijst

| tool                | voor                     | rol                                 | installatie                  |
| ------------------- | ------------------------ | ----------------------------------- | ---------------------------- |
| basedpyright        | python                   | taalserver (types, hover)           | `brew "basedpyright"`        |
| ruff                | python                   | linter-server én formatter          | `brew "ruff"`                |
| vtsls               | javascript               | taalserver                          | `brew "vtsls"`               |
| prettierd           | javascript/json/markdown | formatter                           | `brew "prettierd"`           |
| jdtls               | java                     | taalserver én formatter             | `brew "jdtls"`               |
| lua-language-server | lua                      | taalserver                          | `brew "lua-language-server"` |
| stylua              | lua                      | formatter                           | `brew "stylua"`              |
| clangd              | c                        | taalserver, clang-tidy én formatter | Xcode Command Line Tools     |
| rust-analyzer       | rust                     | taalserver                          | rustup-component             |
| rustfmt             | rust                     | formatter                           | rustup-component             |
| clippy              | rust                     | linter                              | rustup-component             |
| tree-sitter-cli     | alle talen               | parsers bouwen (nvim-treesitter)    | `brew "tree-sitter-cli"`     |
| ripgrep             | pickers en :grep         | de zoekmachine achter beide         | `brew "ripgrep"`             |

Alle brew-tools in één keer (staat ook in de Brewfile):

    brew install basedpyright jdtls lua-language-server \
      prettierd ripgrep ruff stylua tree-sitter-cli vtsls

## Wie zoekt wat

- `lsp/*.lua` — elke server start via zijn `cmd` op naam: `lua-language-server`,
  `basedpyright-langserver`, `ruff server`, `clangd`, `rust-analyzer`, `vtsls`
- conform — formatters op naam: `prettierd`, `stylua`, `ruff`, `rustfmt`
- rust — `rust-analyzer`, `rustfmt` en `clippy` komen uit de actieve
  rustup-toolchain
- nvim-treesitter — gebruikt de `tree-sitter`-CLI voor het bouwen van parsers
  (brew-formula heet tree-sitter-cli; kale "tree-sitter" is alleen de bibliotheek)
- jdtls — `config/jdtls.lua` zoekt `jdtls` met `exepath()` en waarschuwt als
  hij ontbreekt

## Rust installeren en bijwerken

Op een nieuwe machine installeer je eerst rustup via de officiële installer:

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustup set profile default
    rustup default stable
    rustup component add rust-analyzer rustfmt clippy

Het `default`-profiel is geschikt voor ontwikkeling en bevat rustfmt en clippy;
de laatste opdracht maakt de drie benodigde componenten ook expliciet. Bijwerken:

    rustup update stable
    rustup self update
    rustup check

Cargo blijft in `~/.cargo`: daar horen binaries, downloads, Git-caches en
eventuele lokale credentialbestanden thuis. Alleen de deelbare instellingen
staan in `~/.config/cargo/config.toml`; `~/.cargo/config.toml` is er een symlink
naar:

    ln -s ~/.config/cargo/config.toml ~/.cargo/config.toml

De config bevat geen geheimen. Hij geeft voor registrytokens voorrang aan de
macOS Keychain en houdt Cargo's tokenprovider als fallback; zet een token dus
nooit rechtstreeks in dit bestand.

Een project kan eigen Cargo-instellingen toevoegen in `.cargo/config.toml` en
een toolchain vastpinnen met `rust-toolchain.toml`. Pin globaal niets en gebruik
nightly alleen als een project dat echt vereist.

## Waarom clang-format er niet bij hoeft

Voor C staat er geen formatter in conform, en dat is geen omissie: clangd
doet het zelf. Hij meldt `documentFormattingProvider` en formatteert via de
LSP, dus `gq` en format-on-save lopen via de server (format.lua,
`lsp_format = 'fallback'`).

Nagemeten: `clang-format` staat hier niet in PATH en toch komt er uit een
rommelige `main()` netjes ingesprongen C terug. clangd roept dus geen los
binary aan — de formatteermotor (LLVM's libFormat, dezelfde die
clang-format gebruikt) zit ín clangd.

Een `.clang-format` in je project leest hij ook. Getest met
`IndentWidth: 8` en `BreakBeforeBraces: Allman`, en dat komt er precies zo
uit. Je stelt de stijl dus in met dat bestand, niet met een extra tool.

`brew install clang-format` heeft daarom geen zin zolang je alles vanuit
nvim doet. Het zou een tweede binary zijn die hetzelfde doet met dezelfde
config. Alleen als je buiten de editor wilt formatteren — een pre-commit
hook, een CI-stap, of `clang-format -i` over een hele map — is het
installeren waard.

Welke stijl hij dan aanhoudt, en waar dat bestand staat: formatteren.md.

## Waarom vtsls en niet typescript-language-server

Tot 27-08-2026 stond hier typescript-language-server. Die brak: het is een
vertaallaag bovenop `tsserver.js` uit het npm-pakket `typescript`, en brew tilde
typescript naar 7.x — de Go-herschrijving, die geen `tsserver.js` meer meelevert.
Zonder `node_modules` in het project vindt hij dan niets:

    Could not find a valid TypeScript installation.

`tsserver.path` zetten helpt niet, want er is geen doel meer om naar te wijzen.

De Go-binary is zelf óók een LSP-server (`tsc --lsp --stdio`, meldt zich als
typescript-go) en dat leek de simpelste uitweg, maar 7.0.2 declareert wel
`quickfix` en levert er geen. Gemeten op `s.toUpperCasee()`:

    typescript-go   0 code actions
    vtsls          20 code actions, waaronder "Change spelling to 'toUpperCase'"

Op een selectie van drie regels: 0 refactorings tegen 17, inclusief extract
function en extract constant. vtsls pint zijn eigen `typescript` 5.9.3 vast en
staat daarmee los van wat brew met de formula doet.

De prijs is een node-proces in plaats van een 23 MB Go-binary — trager opstarten,
meer geheugen. Voor losse oefenbestanden weegt dat niet op tegen het verlies van
alle quickfixes.

## Waarom brew en geen mason

Nagemeten op 22-08-2026: brew stond voor álle tools hierboven exact op de
nieuwste upstream-release, en Apple's clangd op de actuele LLVM-generatie.
homebrew-core bumpt populaire formulas binnen uren tot dagen, dus "brew loopt
achter op mason" gaat hier niet op — en één pakketbeheerder scheelt een
tweede installatiepad in nvim.

## Nieuw of stuk

- ontbrekende tool: `brew bundle --file ~/.config/Brewfile`
- alles updaten: `brew upgrade`
- Rust bijwerken: `rustup update stable && rustup self update`
- controleren wat nvim kan vinden: `:checkhealth`

Plugins en parsers hebben twee aparte updatecycli. Werk ze daarom in deze
volgorde bij:

1. `:lua vim.pack.update()` en de gekozen pluginupdates bevestigen
2. nvim herstarten, zodat de nieuwe plugincode actief is
3. `:TSUpdate`, zodat de parsers bij de gepinde nvim-treesitter-versie passen
4. `:checkhealth nvim-treesitter conform vim.lsp`
