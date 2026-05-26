#!/bin/bash

source "$CONFIG_DIR/colors.sh"

PLUGIN_DIR="$CONFIG_DIR/plugins"
FONT="JetBrainsMono Nerd Font"

BRACKET_ITEM=(
	background.drawing=off
	icon.font="$FONT:Bold:13.0"
	label.font="$FONT:Semibold:12.0"
	icon.y_offset=0
	label.y_offset=0
	icon.padding_left=6
	icon.padding_right=2
	label.padding_left=2
	label.padding_right=6
)

sketchybar --add item cpu right \
	--set cpu \
	"${BRACKET_ITEM[@]}" \
	update_freq=5 \
	script="$PLUGIN_DIR/cpu.sh"

sketchybar --add item memory right \
	--set memory \
	"${BRACKET_ITEM[@]}" \
	update_freq=15 \
	script="$PLUGIN_DIR/memory.sh"

sketchybar --add item disk right \
	--set disk \
	"${BRACKET_ITEM[@]}" \
	update_freq=300 \
	script="$PLUGIN_DIR/disk.sh"
