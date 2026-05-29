#!/bin/bash
# Shared helpers for bootstrap / restore.

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)}"
DOTFILES_BACKUP_ROOT="${DOTFILES_BACKUP_ROOT:-$HOME/.dotfiles-backup}"

DOTFILES_PACKAGES=(
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

dotfiles_is_managed() {
	local target=$1
	[[ -L $target ]] || return 1
	local dest
	dest=$(readlink "$target") || return 1
	[[ $dest == "$DOTFILES_DIR"/* ]]
}

dotfiles_list_targets() {
	local pkg=$1
	local pkg_dir="$DOTFILES_DIR/$pkg"
	[[ -d $pkg_dir ]] || return 0

	local src rel
	while IFS= read -r -d '' src; do
		rel=${src#"$pkg_dir"/}
		printf '%s\n' "$rel"
	done < <(find "$pkg_dir" -type f ! -name '.DS_Store' -print0)
}

dotfiles_backup_existing() {
	local backup_dir=$1
	local files_dir="$backup_dir/files"
	local manifest="$backup_dir/manifest.tsv"
	local backed_up=0

	mkdir -p "$files_dir"
	: >"$manifest"

	for pkg in "${DOTFILES_PACKAGES[@]}"; do
		[[ -d $DOTFILES_DIR/$pkg ]] || continue

		local rel target backup_dest
		while IFS= read -r rel; do
			[[ -n $rel ]] || continue
			target="$HOME/$rel"

			if [[ ! -e $target && ! -L $target ]]; then
				continue
			fi

			if dotfiles_is_managed "$target"; then
				continue
			fi

			if [[ -d $target && ! -L $target ]]; then
				continue
			fi

			backup_dest="$files_dir/$rel"
			mkdir -p "$(dirname "$backup_dest")"

			if [[ -L $target ]]; then
				readlink "$target" >"$backup_dest.link"
				printf '%s\tsymlink\n' "$rel" >>"$manifest"
			elif [[ -f $target ]]; then
				cp -p "$target" "$backup_dest"
				printf '%s\tfile\n' "$rel" >>"$manifest"
			else
				continue
			fi

			backed_up=$((backed_up + 1))
			echo "  backup: ~/$rel"
		done < <(dotfiles_list_targets "$pkg")
	done

	printf '%s' "$backup_dir" >"$DOTFILES_BACKUP_ROOT/latest"
	echo "$backed_up"
}

dotfiles_stow_all() {
	local pkg
	for pkg in "${DOTFILES_PACKAGES[@]}"; do
		if [[ -d $DOTFILES_DIR/$pkg ]]; then
			stow --target="$HOME" "$pkg"
			echo "  ✓ stow $pkg"
		fi
	done
}

dotfiles_unstow_all() {
	local pkg
	for pkg in "${DOTFILES_PACKAGES[@]}"; do
		if [[ -d $DOTFILES_DIR/$pkg ]]; then
			stow -D --target="$HOME" "$pkg" 2>/dev/null || true
			echo "  ✓ unstow $pkg"
		fi
	done
}

dotfiles_restore_backup() {
	local backup_dir=$1
	local files_dir="$backup_dir/files"
	local manifest="$backup_dir/manifest.tsv"

	[[ -f $manifest ]] || {
		echo "No manifest in $backup_dir" >&2
		return 1
	}

	local rel kind target backup_file link_target
	while IFS=$'\t' read -r rel kind; do
		[[ -n $rel ]] || continue
		target="$HOME/$rel"
		backup_file="$files_dir/$rel"

		if [[ -L $target ]] && dotfiles_is_managed "$target"; then
			rm "$target"
		elif [[ -f $target ]] && dotfiles_is_managed "$target"; then
			rm "$target"
		fi

		mkdir -p "$(dirname "$target")"

		case "$kind" in
		symlink)
			link_target=$(<"$backup_file.link")
			ln -sf "$link_target" "$target"
			;;
		file)
			cp -p "$backup_file" "$target"
			;;
		esac

		echo "  restore: ~/$rel"
	done <"$manifest"
}

dotfiles_install_opencode_plugins() {
	if [[ -f $HOME/.config/opencode/package.json ]]; then
		echo "Installing opencode plugins..."
		if command -v npm >/dev/null; then
			npm install --prefix "$HOME/.config/opencode" || true
		fi
	fi
}
