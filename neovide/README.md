# Neovide archive

Neovide is currently not part of the active setup. Ghostty is the default terminal UI for Neovim.

Kept here for a possible future reinstall:

- `config.toml`: Neovide application config.
- `nvide.lua`: former Neovim-side Neovide integration.
- `shell.zsh`: optional zsh helper alias.

To restore the Neovim integration, move `nvide.lua` back to:

```text
~/.config/nvim/lua/config/neovide.lua
```

Then add this near the top of `~/.config/nvim/init.lua`, after `require('set')`:

```lua
require('config.neovide').setup()
```

To restore the shell helper, source `shell.zsh` from `~/.config/zshrc` or copy the alias back.

No active Neovim Remote (`nvr` / `neovim-remote`) config was found in the current Neovim or zsh setup.
