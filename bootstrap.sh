#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)}"
BREWFILE="$DOTFILES_DIR/Brewfile"

DRY_RUN=0
YES=0
SKIP_BREW=0
SKIP_CHECKS=0
INSTALL_HOMEBREW=0

usage() {
  cat <<EOF
Usage: ./bootstrap.sh [options]

Run this after cloning the dotfiles repo to ~/.config.

Options:
  --dry-run            Print what would happen without changing anything.
  --yes               Skip the safety confirmation prompt.
  --install-homebrew  Install Homebrew if it is missing.
  --skip-brew         Do not run brew bundle.
  --skip-checks       Do not run zsh/nvim validation checks.
  -h, --help          Show this help.

Before first full use on a new Mac, set up your GitHub SSH key.
EOF
}

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2
}

die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'dry-run:'
    printf ' %q' "$@"
    printf '\n'
    return
  fi

  "$@"
}

write_file() {
  local target="$1"
  local content="$2"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'dry-run: write %s\n' "$target"
    return
  fi

  printf '%s\n' "$content" >"$target"
}

backup_path() {
  local path="$1"
  local backup="$path.backup.$(date +%Y%m%d-%H%M%S)"

  log "Backing up $path to $backup"
  run mv "$path" "$backup"
}

ensure_dir() {
  local dir="$1"
  [[ -d "$dir" ]] && return
  log "Creating $dir"
  run mkdir -p "$dir"
}

ensure_symlink() {
  local source="$1"
  local target="$2"

  [[ -e "$source" ]] || die "Missing source for symlink: $source"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      log "Symlink ok: $target"
      return
    fi
    backup_path "$target"
  elif [[ -e "$target" ]]; then
    backup_path "$target"
  fi

  log "Linking $target -> $source"
  run ln -s "$source" "$target"
}

ensure_zshrc_loader() {
  local target="$HOME/.zshrc"
  local wanted='[[ -r "$HOME/.config/zshrc" ]] && . "$HOME/.config/zshrc"'

  if [[ -f "$target" ]] && grep -Fxq "$wanted" "$target"; then
    log "zsh loader ok: $target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup_path "$target"
  fi

  log "Writing $target loader"
  write_file "$target" "$wanted"
}

ensure_zshenv() {
  local target="$HOME/.zshenv"
  local wanted='[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"'

  if [[ -f "$target" ]] && grep -Fxq "$wanted" "$target"; then
    log "zshenv ok: $target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup_path "$target"
  fi

  log "Writing $target"
  write_file "$target" "$wanted"
}

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    printf '%s\n' /opt/homebrew/bin/brew
    return
  fi

  if [[ -x /usr/local/bin/brew ]]; then
    printf '%s\n' /usr/local/bin/brew
    return
  fi
}

install_homebrew() {
  local installer_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

  log "Installing Homebrew"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'dry-run: curl -fsSL %q | /bin/bash\n' "$installer_url"
    return
  fi

  /bin/bash -c "$(curl -fsSL "$installer_url")"
}

brew_bundle() {
  [[ "$SKIP_BREW" -eq 1 ]] && return
  [[ -f "$BREWFILE" ]] || die "Missing Brewfile: $BREWFILE"

  local brew_bin
  brew_bin="$(find_brew || true)"

  if [[ -z "$brew_bin" ]]; then
    if [[ "$INSTALL_HOMEBREW" -eq 1 ]]; then
      install_homebrew
      brew_bin="$(find_brew || true)"
    else
      warn "Homebrew is missing. Re-run with --install-homebrew or install it manually."
      return
    fi
  fi

  [[ -n "$brew_bin" ]] || die "Homebrew install did not expose brew on PATH"

  log "Running brew bundle"
  run "$brew_bin" bundle --file "$BREWFILE"
}

warn_about_ssh_plugins() {
  local nvim_init="$DOTFILES_DIR/nvim/init.lua"

  [[ -f "$nvim_init" ]] || return
  grep -q 'git@github.com' "$nvim_init" || return
  compgen -G "$HOME/.ssh/id_*" >/dev/null || warn "Neovim uses git@github.com plugins; set up GitHub SSH before first plugin install."
}

validate_setup() {
  [[ "$SKIP_CHECKS" -eq 1 ]] && return

  log "Validating zsh config"
  run zsh -n "$DOTFILES_DIR/zshrc"

  warn_about_ssh_plugins

  if command -v nvim >/dev/null 2>&1; then
    log "Validating Neovim config"
    if ! run env GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND='ssh -o BatchMode=yes' nvim --headless --cmd 'set shadafile=NONE' -u "$DOTFILES_DIR/nvim/init.lua" +qa; then
      warn "Neovim validation failed. Bootstrap completed, but open nvim manually after checking plugins/tools."
    fi
  else
    warn "nvim not found on PATH; skipping Neovim validation."
  fi
}

print_next_steps() {
  cat <<EOF

Bootstrap complete.

Optional manual steps:
  1. Restart the terminal or run: exec zsh
  2. Set up your GitHub SSH key, then verify: ssh -T git@github.com
  3. In Neovim, run :MasonEnsureTools if language tools are missing.
  4. Open Ghostty once and reload config if needed.

Neovide and neovim-remote are intentionally not restored by this bootstrap.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --yes)
      YES=1
      ;;
    --install-homebrew)
      INSTALL_HOMEBREW=1
      ;;
    --skip-brew)
      SKIP_BREW=1
      ;;
    --skip-checks)
      SKIP_CHECKS=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      die "Unknown option: $1"
      ;;
  esac
  shift
done

[[ "$(uname -s)" == "Darwin" ]] || warn "This bootstrap is tuned for macOS."

[[ "$DOTFILES_DIR" == "$HOME/.config" ]] || die "Clone or move this repo to ~/.config before running. Current path: $DOTFILES_DIR"

cat <<EOF
This will bootstrap your dotfiles from:
  $DOTFILES_DIR

It will:
  - create ~/bin and ~/.local/bin
  - ensure ~/.zshrc loads ~/.config/zshrc
  - ensure ~/.zshenv loads Cargo env when present
  - link ~/.ripgreprc and ~/.ideavimrc to this repo
  - run brew bundle from $BREWFILE unless --skip-brew is used
  - validate zsh and Neovim unless --skip-checks is used

Existing conflicting files are backed up with a timestamp.

Important:
  Set up your GitHub SSH key on a new Mac before first full Neovim use.
  Your config uses git@github.com plugin URLs.
EOF

if [[ "$YES" -ne 1 ]]; then
  printf '\nAre you sure you want to continue? [y/N] '
  read -r reply
  case "$reply" in
    y|Y|yes|YES)
      ;;
    *)
      printf 'Aborted.\n'
      exit 0
      ;;
  esac
fi

ensure_dir "$HOME/bin"
ensure_dir "$HOME/.local/bin"
ensure_zshrc_loader
ensure_zshenv
ensure_symlink "$DOTFILES_DIR/ripgreprc" "$HOME/.ripgreprc"
ensure_symlink "$DOTFILES_DIR/ideavim/ideavimrc" "$HOME/.ideavimrc"
brew_bundle
validate_setup
print_next_steps
