# editor
export EDITOR="nvim"
export VISUAL="nvim"
export COLORTERM=truecolor

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

# user local bin (uv, etc.)
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

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

# uv shell hook (created by: curl -LsSf https://astral.sh/uv/install.sh | sh)
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
