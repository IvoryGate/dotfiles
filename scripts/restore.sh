#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)
# shellcheck source=lib/dotfiles.sh
source "$SCRIPT_DIR/lib/dotfiles.sh"

usage() {
	cat <<EOF
Usage: $(basename "$0") [options] [backup-dir]

Unstow dotfiles and restore configs from a previous bootstrap backup.

Options:
  -l, --list      List available backups
  -h, --help      Show this help

If backup-dir is omitted, uses the most recent backup ($DOTFILES_BACKUP_ROOT/latest).
EOF
}

list_backups() {
	if [[ ! -d $DOTFILES_BACKUP_ROOT ]]; then
		echo "No backups found."
		return 0
	fi

	local latest=""
	[[ -f $DOTFILES_BACKUP_ROOT/latest ]] && latest=$(<"$DOTFILES_BACKUP_ROOT/latest")

	echo "Backups in $DOTFILES_BACKUP_ROOT:"
	local dir
	for dir in "$DOTFILES_BACKUP_ROOT"/*; do
		[[ -d $dir ]] || continue
		[[ -f $dir/manifest.tsv ]] || continue
		local marker=""
		[[ $dir == "$latest" ]] && marker=" (latest)"
		printf '  %s%s\n' "$(basename "$dir")" "$marker"
	done
}

BACKUP_DIR=""
while [[ $# -gt 0 ]]; do
	case "$1" in
	-l | --list)
		list_backups
		exit 0
		;;
	-h | --help)
		usage
		exit 0
		;;
	-*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	*)
		BACKUP_DIR=$1
		shift
		;;
	esac
done

if [[ -z $BACKUP_DIR ]]; then
	if [[ ! -f $DOTFILES_BACKUP_ROOT/latest ]]; then
		echo "No backup found. Run bootstrap.sh first or pass a backup directory." >&2
		exit 1
	fi
	BACKUP_DIR=$(<"$DOTFILES_BACKUP_ROOT/latest")
fi

if [[ ! -d $BACKUP_DIR || ! -f $BACKUP_DIR/manifest.tsv ]]; then
	echo "Invalid backup directory: $BACKUP_DIR" >&2
	exit 1
fi

echo "Restoring from: $BACKUP_DIR"
echo "Unstowing dotfiles..."
dotfiles_unstow_all

echo "Restoring backed-up files..."
dotfiles_restore_backup "$BACKUP_DIR"

echo "Done. Your previous configs have been restored."
