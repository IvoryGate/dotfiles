#!/bin/bash

source "$CONFIG_DIR/colors.sh"

PLUGIN_DIR="$CONFIG_DIR/plugins"
FONT="JetBrainsMono Nerd Font"
APP_FONT="sketchybar-app-font:Regular:14.0"

sketchybar --add event aerospace_workspace_change

if command -v aerospace >/dev/null 2>&1; then
	for sid in $(aerospace list-workspaces --all 2>/dev/null); do
		sketchybar --add item "space.$sid" left \
			--subscribe "space.$sid" aerospace_workspace_change \
			--set "space.$sid" \
			icon="$sid" \
			icon.font="$FONT:Bold:13.0" \
			icon.padding_left=8 \
			icon.padding_right=4 \
			label.font="$APP_FONT" \
			label.padding_right=8 \
			label.y_offset=-1 \
			background.drawing=off \
			click_script="aerospace workspace $sid" \
			script="$PLUGIN_DIR/aerospace.sh $sid"
	done
	"$PLUGIN_DIR/aerospace_apps.sh"
fi

sketchybar --add item space_focus left \
	--set space_focus \
	icon="󰍡" \
	icon.color="$MUTED" \
	icon.font="$FONT:Bold:12.0" \
	label.font="$APP_FONT" \
	label.padding_right=8 \
	label.y_offset=-1 \
	background.drawing=off \
	script="$PLUGIN_DIR/space_focus.sh" \
	--subscribe space_focus aerospace_workspace_change front_app_switched
