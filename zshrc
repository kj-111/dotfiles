bindkey -e
setopt prompt_subst INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS HIST_VERIFY AUTO_CD NOMATCH

path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.config/java-scratch
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/bin
  $path
)
export PATH
export HISTFILE=~/.zsh_history HISTSIZE=20000 SAVEHIST=20000
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgreprc

export JAVA_HOME=$(/usr/libexec/java_home)
alias java11='export JAVA_HOME=$(/usr/libexec/java_home -v 11)'
alias java21='export JAVA_HOME=$(/usr/libexec/java_home -v 21)'
alias java25='export JAVA_HOME=$(/usr/libexec/java_home -v 25)'

autoload -Uz compinit
compinit -i
zstyle ':completion:*' menu select

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --no-ignore --exclude .git'

source /opt/homebrew/opt/fzf/shell/completion.zsh
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

alias c='clear' q='exit'
alias nv='nvim'
alias lg='lazygit' dash='dashboard'
mkcd() { mkdir -p "$1" && cd "$1" }

r() { exec zsh }

eval "$(zoxide init zsh --cmd cd)"

git_branch_name() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -n $branch ]] && echo " %B%F{#B48EAD} $branch%f%b"
}

prompt='%B%F{#88C0D0}%2~%f%b$(git_branch_name) %B%F{#EBCB8B}❯%f%b '
