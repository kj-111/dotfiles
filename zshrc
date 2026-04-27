bindkey -e
setopt prompt_subst INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS HIST_VERIFY AUTO_CD NOMATCH

path=(
  $HOME/bin
  $HOME/.local/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/bin
  $path
)
export PATH
export HISTFILE=~/.zsh_history HISTSIZE=20000 SAVEHIST=20000
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgreprc

if /usr/libexec/java_home >/dev/null 2>&1; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi
alias java11='export JAVA_HOME=$(/usr/libexec/java_home -v 11)'
alias java21='export JAVA_HOME=$(/usr/libexec/java_home -v 21)'
alias java25='export JAVA_HOME=$(/usr/libexec/java_home -v 25)'

autoload -Uz compinit
compinit -i
zstyle ':completion:*' menu select

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --no-ignore --exclude .git'

[[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
[[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[[ -r $HOME/.config/fzf/key-bindings.zsh ]] && source $HOME/.config/fzf/key-bindings.zsh

alias c='clear' q='exit'
alias nv='nvim' vi='nvim' vim='nvim'
alias lg='lazygit' dash='dashboard'
mkcd() { mkdir -p "$1" && cd "$1" }

r() { exec zsh }

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

git_branch_name() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -n $branch ]] && echo " %B%F{#B48EAD} $branch%f%b"
}

prompt_arrow() {
  if [[ -n $TMUX ]]; then
    echo "%B%F{#5E81AC}❯%f%b"
  else
    echo "%B%F{#BF616A}❭%f%b"
  fi
}

printf '\33c\e[3J' #beter oplossing is touch ~/.hushlogin
prompt='%B%F{#88C0D0}%2~%f%b $(prompt_arrow) '
# prompt='%B%F{#88C0D0}%2~%f%b$(git_branch_name) $(prompt_arrow) '
