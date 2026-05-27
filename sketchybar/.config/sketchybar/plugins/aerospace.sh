#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

SID="${1:-${NAME#space.}}"
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

if [ "$SID" = "$FOCUSED" ]; then
	sketchybar --set "$NAME" \
		icon.color="$ACCENT_FG" \
		label.color="$ACCENT_FG" \
		background.drawing=on \
		background.color="$ACCENT" \
		background.border_color="$ACCENT"
else
	sketchybar --set "$NAME" \
		icon.color="$LABEL_COLOR" \
		label.color="$MUTED" \
		background.drawing=off \
		background.border_color="$BACKGROUND_2"
fi

# Refresh app icons on all workspaces when focus changes
if [ -n "$FOCUSED_WORKSPACE" ]; then
	"$CONFIG_DIR/plugins/aerospace_apps.sh"
fi
