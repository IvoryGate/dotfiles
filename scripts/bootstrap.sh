#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)
# shellcheck source=lib/dotfiles.sh
source "$SCRIPT_DIR/lib/dotfiles.sh"

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]

Back up existing config files, then stow dotfiles into \$HOME.

Options:
  --skip-backup   Apply dotfiles without creating a new backup
  -h, --help      Show this help
EOF
}

SKIP_BACKUP=0
while [[ $# -gt 0 ]]; do
	case "$1" in
	--skip-backup)
		SKIP_BACKUP=1
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	esac
done

if ! command -v stow >/dev/null; then
	echo "stow is required. Install with: brew install stow" >&2
	exit 1
fi

echo "Dotfiles: $DOTFILES_DIR"

if [[ $SKIP_BACKUP -eq 0 ]]; then
	ts=$(date +%Y%m%d-%H%M%S)
	backup_dir="$DOTFILES_BACKUP_ROOT/$ts"
	mkdir -p "$backup_dir"
	echo "Backing up existing configs to $backup_dir"
	count=$(dotfiles_backup_existing "$backup_dir")
	echo "Backed up $count file(s). Latest pointer: $DOTFILES_BACKUP_ROOT/latest"
else
	echo "Skipping backup (--skip-backup)"
fi

echo "Stowing packages..."
dotfiles_stow_all

dotfiles_install_opencode_plugins

cat <<EOF

Done.

Next steps:
  brew bundle --file=$DOTFILES_DIR/Brewfile   # installs fonts + apps (incl. macism for nvim IME)
  sketchybar --reload   # if sketchybar is installed
  # Neovim IME: keep only ABC + one Chinese source in System Settings → Keyboard
  # Ghostty: Cmd+Q and reopen after font install if icons look wrong

To restore your previous configs:
  $SCRIPT_DIR/restore.sh
EOF
