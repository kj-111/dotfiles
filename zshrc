# Setup nieuwe computer:
#   ssh-key aanmaken en op github zetten                     # anders faalt de clone hieronder
#   Homebrew installeren (brew.sh)
#   git clone git@github.com:kj-111/dotfiles.git ~/.config   # backup: git@gitlab.com:kjlab-111/dotfiles.git
#   echo '[[ -r "$HOME/.config/zshrc" ]] && . "$HOME/.config/zshrc"' > ~/.zshrc   # zsh leest hardcoded ~/.zshrc
#   touch ~/.hushlogin                                       # dempt "Last login"-banner
#   brew bundle --file ~/.config/Brewfile                    # apps uit gui-apps.txt handmatig
#   ln -s ~/.config/tools/jinit/jinit ~/.local/bin/jinit     # zie tools/README.md
#   toetsen en macOS-instellingen: hyperkey/README.md

bindkey -e
setopt prompt_subst INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS HIST_VERIFY AUTO_CD NOMATCH

typeset -U path PATH
path=(
  $HOME/.local/bin
  $HOME/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/bin
  $path
)
export PATH
export HISTFILE=~/.zsh_history HISTSIZE=20000 SAVEHIST=20000
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgreprc
export CLAUDE_CONFIG_DIR=$HOME/.config/claude
export CODEX_HOME=$HOME/.config/codex
export PRETTIERD_DEFAULT_CONFIG=$HOME/.config/prettier/.prettierrc

if /usr/libexec/java_home >/dev/null 2>&1; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi
alias java21='export JAVA_HOME=$(/usr/libexec/java_home -v 21)'
alias java25='export JAVA_HOME=$(/usr/libexec/java_home -v 25)'

autoload -Uz compinit
compinit -i
zstyle ':completion:*' menu select

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse"
export FZF_DEFAULT_COMMAND="rg --files --hidden --no-ignore --glob '!.git'"

[[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
[[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

alias c='clear' q='exit' nv='nvim' nvide='neovide' sioyek='open -a Sioyek' lg='lazygit'

mkcd() { mkdir -p "$1" && cd "$1" }

r() { exec zsh }

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

git_branch_name() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -n $branch ]] && echo " %B%F{#B48EAD}($branch)%f%b"
}

PROMPT='%B%F{#81A1C1}%2~%f%b$(git_branch_name) %B%F{#5E81AC}%#%f%b '
