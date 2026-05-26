#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

FOCUSED="$(aerospace list-workspaces --focused 2>/dev/null)"
[ -z "$FOCUSED" ] && exit 0

apps="$(aerospace list-windows --workspace "$FOCUSED" --format '%{app-name}' 2>/dev/null | sort -u)"
strip=""
if [ -n "$apps" ]; then
	while IFS= read -r app; do
		[ -z "$app" ] && continue
		strip+=" $("$CONFIG_DIR/plugins/icon_map.sh" "$app")"
	done <<< "$apps"
else
	strip=" —"
fi

sketchybar --set "$NAME" label="$strip"
