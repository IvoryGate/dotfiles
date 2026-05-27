# greeting
set -g fish_greeting ""

# editor
set -gx EDITOR "nvim"
set -gx VISUAL "nvim"

# homebrew
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end

# rust/cargo
if test -d "$HOME/.cargo/bin"
    fish_add_path -P "$HOME/.cargo/bin"
end

# aliases
alias ll="ls -ahlt"
alias cdf='cd "$(dirname "$(find . -type f 2>/dev/null | fzf)")"'

# cli tools
alias nf="neofetch"
alias matrix="cmatrix -C green -s"
alias fireworks="firework -g"
alias oc="opencode"
alias todo="dooit"

# starship prompt
if status is-interactive; and command -q starship
    set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
    starship init fish | source
end