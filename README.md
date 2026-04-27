# dotfiles

Portable shell and GUI tool configuration migrated from `anrim-dotfiles`, plus local Zsh, Vim, and Neofetch snapshots.

## One-shot restore

From this directory:

```bash
./install.sh
```

Or:

```bash
bash scripts/restore.sh
```

Environment knobs:

- `SKIP_BREW=1` — do not run `brew bundle` (only symlinks and TPM; use this if dependencies are already installed)
- `Brewfile` — minimal set aligned with the configs in this repo. The older full snapshot is `Brewfile.full` if you ever want `brew bundle --file=Brewfile.full`
- `SKIP_FISH_CHSH=1` — do not run `chsh` to fish
- `DOTFILES_BACKUP_ROOT=/path` — where to move replaced files (default: `~/.dotfiles-backup`)

Existing files and directories that would be replaced are moved under `~/.dotfiles-backup/<timestamp>/` before symlinks are created.

## Raycast

Import the exported `.rayconfig` under `raycast/` via Raycast → Settings → Advanced → Import.

## Vim plugins

`vim/runtime/plugged` is not tracked. After restore, open Vim and run your plugin manager install step (e.g. `:PlugInstall`).
