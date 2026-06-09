#!/bin/bash
# Hyper+1..9 workspace switch (Karabiner + aerospace.toml).
# Single built-in: workspace 1..9 on the laptop screen.
# Dual display: 1,3,5,7,9 → built-in; 2,4,6,8 → external (secondary).
set -euo pipefail

ws="${1:-}"
if [[ ! $ws =~ ^[1-9]$ ]]; then
	echo "usage: workspace-key.sh <1-9>" >&2
	exit 1
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Fast display count — do not use `aerospace list-monitors` (can hang).
monitors=$(osascript -e 'tell application "System Events" to count of desktops' 2>/dev/null || echo 1)

if [[ $monitors -ge 2 ]]; then
	if (( ws % 2 == 1 )); then
		aerospace move-workspace-to-monitor --workspace "$ws" 'built-in'
	else
		aerospace move-workspace-to-monitor --workspace "$ws" 'secondary'
	fi
fi

exec aerospace workspace "$ws"
