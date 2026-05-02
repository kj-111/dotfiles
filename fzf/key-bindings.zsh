# Local fzf zsh key bindings.
#
# Based on Homebrew fzf's shell/key-bindings.zsh, but kept in dotfiles so Brew
# upgrades do not overwrite local behavior.
# - Ctrl-F: select a file or directory and open it in Neovim.
# - Ctrl-E: select a directory and open it in Neovim.

if [[ "${FZF_CTRL_T_COMMAND-x}" != "" ]]; then
  fzf-file-widget() {
    setopt localoptions pipefail no_aliases 2> /dev/null

    local file
    file="$(
      FZF_DEFAULT_COMMAND=${FZF_CTRL_T_COMMAND:-} \
      FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=file,dir,follow,hidden --scheme=path" "${FZF_CTRL_T_OPTS-} +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) < /dev/tty
    )"
    local ret=$?

    if (( ret != 0 )); then
      zle reset-prompt
      return $ret
    fi
    if [[ -z "$file" ]]; then
      zle redisplay
      return 0
    fi

    zle push-line
    BUFFER="nvim -- ${(q)file:a}"
    zle accept-line
    local ret=$?
    unset file
    zle reset-prompt
    return $ret
  }

  zle     -N            fzf-file-widget
  bindkey -M emacs '^F' fzf-file-widget
  bindkey -M vicmd '^F' fzf-file-widget
  bindkey -M viins '^F' fzf-file-widget
fi

if [[ "${FZF_ALT_C_COMMAND-x}" != "" ]]; then
  fzf-cd-widget() {
    setopt localoptions pipefail no_aliases 2> /dev/null

    local dir
    dir="$(
      FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
      FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) < /dev/tty
    )"

    if [[ -z "$dir" ]]; then
      zle redisplay
      return 0
    fi

    zle push-line
    BUFFER="nvim -- ${(q)dir:a}"
    zle accept-line
    local ret=$?
    unset dir
    zle reset-prompt
    return $ret
  }

  zle     -N             fzf-cd-widget
  bindkey -M emacs '^E' fzf-cd-widget
  bindkey -M vicmd '^E' fzf-cd-widget
  bindkey -M viins '^E' fzf-cd-widget
fi
