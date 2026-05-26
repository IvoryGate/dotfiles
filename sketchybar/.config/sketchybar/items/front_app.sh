#!/bin/bash

source "$CONFIG_DIR/colors.sh"

PLUGIN_DIR="$CONFIG_DIR/plugins"
FONT="JetBrainsMono Nerd Font"
APP_FONT="sketchybar-app-font:Regular:16.0"

sketchybar --add item layout left \
	--set layout \
	update_freq=2 \
	icon.font="$FONT:Bold:13.0" \
	label.font="$FONT:Semibold:12.0" \
	label.color="$MUTED" \
	padding_left=4 \
	background.drawing=on \
	script="$PLUGIN_DIR/layout.sh" \
	click_script="$PLUGIN_DIR/layout_click.sh" \
	--subscribe layout aerospace_workspace_change front_app_switched

sketchybar --add item front_app left \
	--set front_app \
	updates=on \
	icon.font="$APP_FONT" \
	label.font="$FONT:Bold:13.0" \
	label.color="$ACCENT" \
	label.max_chars=24 \
	padding_left=4 \
	background.drawing=on \
	script="$PLUGIN_DIR/front_app.sh" \
	--subscribe front_app front_app_switched
