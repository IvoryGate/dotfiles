#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
hint() { echo -e "${CYAN}[i]${NC} $*"; }
section() { echo -e "\n${YELLOW}── $* ──${NC}"; }
die() {
	echo -e "${RED}[✗]${NC} $*" >&2
	exit 1
}

trap 'die "Error on line $LINENO"' ERR

section "Paths"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_ROOT="${DOTFILES_BACKUP_ROOT:-$HOME/.dotfiles-backup}/$(date +%Y%m%d-%H%M%S)"

info "Dotfiles:  $DOTFILES_DIR"
info "XDG config: $CONFIG_DIR"
info "Backups:   $BACKUP_ROOT (existing files moved here before linking)"

if [[ -f "$DOTFILES_DIR/.gitmodules" ]]; then
	section "Git submodules"
	git -C "$DOTFILES_DIR" submodule update --init --recursive || warn "submodule update failed (offline?)"
fi

mkdir -p "$CONFIG_DIR" "$BACKUP_ROOT"
touch "$HOME/.hushlogin"

home_rel() {
	local p="$1"
	echo "${p#$HOME/}"
}

backup_and_remove() {
	local target="$1"
	if [[ ! -e "$target" && ! -L "$target" ]]; then
		return 0
	fi
	if [[ -L "$target" ]]; then
		local cur
		cur="$(readlink "$target")"
		if [[ "$cur" == "$DOTFILES_DIR"/* ]]; then
			rm -f "$target"
			info "Removed stale symlink $target"
			return 0
		fi
	fi
	local rel dest
	rel="$(home_rel "$target")"
	dest="$BACKUP_ROOT/$rel"
	mkdir -p "$(dirname "$dest")"
	mv "$target" "$dest"
	info "Backed up ~/$rel → $dest"
}

link_dir() {
	local src="$1" dst="$2"
	[[ -d "$src" ]] || die "Missing directory: $src"
	backup_and_remove "$dst"
	ln -s "$src" "$dst"
	info "Linked dir  $dst → $src"
}

link_file() {
	local src="$1" dst="$2"
	[[ -f "$src" ]] || die "Missing file: $src"
	backup_and_remove "$dst"
	mkdir -p "$(dirname "$dst")"
	ln -s "$src" "$dst"
	info "Linked file $dst → $src"
}

section "XDG config directories"

for name in aerospace tmux fish nvim yazi btop lazygit mole neovide alacritty fastfetch neofetch ghostty starship npm opencode; do
	link_dir "$DOTFILES_DIR/$name" "$CONFIG_DIR/$name"
done

section "Karabiner-Elements"

link_dir "$DOTFILES_DIR/karabiner/config" "$CONFIG_DIR/karabiner"
link_file "$DOTFILES_DIR/karabiner/edn/karabiner.edn" "$CONFIG_DIR/karabiner.edn"

section "AeroSpace (legacy path)"

AERO_TOML="$CONFIG_DIR/aerospace/aerospace.toml"
link_file "$AERO_TOML" "$HOME/.aerospace.toml"

section "Zsh"

link_file "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
if [[ -f "$DOTFILES_DIR/zsh/zprofile" ]]; then
	link_file "$DOTFILES_DIR/zsh/zprofile" "$HOME/.zprofile"
fi
if [[ -f "$DOTFILES_DIR/zsh/zshenv" ]]; then
	link_file "$DOTFILES_DIR/zsh/zshenv" "$HOME/.zshenv"
fi

section "Vim"

link_file "$DOTFILES_DIR/vim/vimrc" "$HOME/.vimrc"
link_dir "$DOTFILES_DIR/vim/runtime" "$HOME/.vim"

section "Raycast"

shopt -s nullglob
RAYCAST_EXPORTS=("$DOTFILES_DIR"/raycast/*.rayconfig)
shopt -u nullglob
if ((${#RAYCAST_EXPORTS[@]})); then
	hint "Raycast (manual): Settings → Backup → Import, then pick:"
	for f in "${RAYCAST_EXPORTS[@]}"; do
		echo "    $f"
	done
else
	hint "No .rayconfig under raycast/ — nothing to import"
fi

section "Tmux Plugin Manager (TPM)"

TPM_DIR="$CONFIG_DIR/tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
	info "TPM already present at $TPM_DIR"
else
	git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" || die "TPM clone failed (network?)"
	info "Cloned TPM"
fi
bash "$TPM_DIR/bin/install_plugins" || warn "TPM install_plugins exited nonzero (offline or partial install)"
info "Tmux plugins step finished"

if [[ "${SKIP_BREW:-}" == "1" ]]; then
	warn "SKIP_BREW=1 — skipping brew bundle"
else
	section "Homebrew bundle"
	if command -v brew &>/dev/null; then
		hint "brew bundle uses Brewfile (see Brewfile.full for a larger list). Slow network: little output until done."
		hint "Link dotfiles only, skip Homebrew: SKIP_BREW=1 ./install.sh"
		BREW_BUNDLE_FAILED=0
		brew bundle install --file="$DOTFILES_DIR/Brewfile" --verbose || BREW_BUNDLE_FAILED=1
		if [[ "$BREW_BUNDLE_FAILED" -eq 1 ]]; then
			warn "brew bundle reported errors. If a formula needs newer Xcode CLT, update it, then re-run:"
			warn "  brew bundle install --file=\"$DOTFILES_DIR/Brewfile\""
			warn "Optional mole (after CLT is current): brew bundle install --file=\"$DOTFILES_DIR/Brewfile.mole\""
		fi
	else
		warn "brew not found; install Homebrew first or set SKIP_BREW=1"
	fi
fi

if [[ "${SKIP_FISH_CHSH:-}" == "1" ]]; then
	warn "SKIP_FISH_CHSH=1 — not changing default shell"
else
	section "Default shell → fish"
	FISH_PATH="$(command -v fish 2>/dev/null || true)"
	if [[ -z "$FISH_PATH" ]]; then
		warn "fish not in PATH; install fish or set SKIP_FISH_CHSH=1"
	else
		if ! grep -qxF "$FISH_PATH" /etc/shells 2>/dev/null; then
			echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
			info "Added $FISH_PATH to /etc/shells"
		fi
		login_shell=""
		if [[ "$(uname -s)" == "Darwin" ]] && command -v dscl &>/dev/null; then
			login_shell="$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '/^UserShell:/ {print $2}')"
		fi
		if [[ -z "$login_shell" ]]; then
			login_shell="${SHELL:-}"
		fi
		if [[ "$login_shell" != "$FISH_PATH" ]]; then
			chsh -s "$FISH_PATH" || warn "chsh failed; set default shell manually"
		else
			info "Login shell is already $FISH_PATH — skipped chsh (no password prompt)"
		fi
		info "Default shell: $FISH_PATH"
	fi
fi

section "Cargo extras"

if command -v cargo &>/dev/null; then
	# So cargo-installed binaries resolve and cargo does not warn about ~/.cargo/bin
	export PATH="${HOME}/.cargo/bin:${PATH}"
	for pkg in cargo-cache cargo-update; do
		if cargo install --list 2>/dev/null | grep -q "^${pkg} "; then
			info "$pkg already installed"
		else
			cargo install "$pkg"
			info "Installed $pkg"
		fi
	done
elif [[ "${SKIP_BREW:-}" == "1" ]]; then
	info "SKIP_BREW=1 — skipped cargo-cache / cargo-update (rust not installed this run)"
else
	warn "cargo not on PATH after brew bundle — run: brew install rust"
fi

echo -e "\n${GREEN}Restore finished.${NC} Previous files are under: $BACKUP_ROOT"

if [[ "${SKIP_BREW:-}" != "1" ]] && [[ "${BREW_BUNDLE_FAILED:-0}" -eq 1 ]]; then
	die "Homebrew bundle had failures (exit 1). Dotfiles were linked; fix brew errors above and re-run brew bundle if needed."
fi
