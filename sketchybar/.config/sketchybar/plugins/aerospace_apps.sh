#!/usr/bin/env bash

update_workspace() {
	local sid="$1"
	local apps strip="" app

	apps=$(aerospace list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null | sort -u)
	if [ -n "$apps" ]; then
		while IFS= read -r app; do
			[ -z "$app" ] && continue
			strip+=" $("$CONFIG_DIR/plugins/icon_map.sh" "$app")"
		done <<< "$apps"
	else
		strip=" —"
	fi

	sketchybar --set "space.$sid" label="$strip"
}

if command -v aerospace >/dev/null 2>&1; then
	for sid in $(aerospace list-workspaces --all 2>/dev/null); do
		update_workspace "$sid"
	done
fi
