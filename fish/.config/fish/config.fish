# greeting
set -g fish_greeting ""

# editor
set -gx EDITOR "nvim"
set -gx VISUAL "nvim"

# homebrew
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end

# aliases
alias ll="ls -ahlt"