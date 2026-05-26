#!/bin/bash

source "$CONFIG_DIR/colors.sh"

PLUGIN_DIR="$CONFIG_DIR/plugins"
FONT="JetBrainsMono Nerd Font"

sketchybar --add item media center \
	--set media \
	icon="$ICON_MEDIA" \
	icon.color="$ACCENT" \
	label.color="$LABEL_COLOR" \
	label.max_chars=48 \
	label.font="$FONT:Semibold:12.0" \
	scroll_texts=on \
	background.drawing=off \
	padding_left=8 \
	padding_right=8 \
	script="$PLUGIN_DIR/media.sh" \
	--subscribe media media_change
