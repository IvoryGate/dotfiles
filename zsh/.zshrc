# editor
export EDITOR="nvim"
export VISUAL="nvim"

# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# auto complete
autoload -Uz compinit
compinit

# starship prompt
eval "$(starship init zsh)"

# aliases
alias ll="ls -ahlt"
alias cdf='cd "$(dirname "$(find . -type f 2>/dev/null | fzf)")"'