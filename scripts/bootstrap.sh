#!/bin/bash
set -euo pipefail

DOTFILES_DIR=$(cd "$(dirname "$0")/.." && pwd -P)

PACKAGES=(
	aerospace
	alacritty
	borders
	btop
	dooit
	fish
	ghostty
	git
	karabiner
	mpv
	neofetch
	nvim
	opencode
	sketchybar
	starship
	tmux
	yazi
	zsh
)

echo "Stowing from $DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
	if [ -d "$DOTFILES_DIR/$pkg" ]; then
		stow --target="$HOME" "$pkg"
		echo "  ✓ $pkg"
	fi
done

if [ -f "$HOME/.config/opencode/package.json" ]; then
	echo "Installing opencode plugins..."
	(command -v npm >/dev/null && npm install --prefix "$HOME/.config/opencode") || true
fi

echo "Done. Run: brew bundle && sketchybar --reload"
