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

# homebrew
if [ -x /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# rust/cargo
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

# aliases
alias ll="ls -ahlt"
alias cdf='cd "$(dirname "$(find . -type f 2>/dev/null | fzf)")"'
alias nf="neofetch"
alias matrix="cmatrix -C green -s"
alias fireworks="firework -g"
alias oc="opencode"
alias todo="dooit"