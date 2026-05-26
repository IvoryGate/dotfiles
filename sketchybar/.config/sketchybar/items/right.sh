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

sketchybar --add item wifi right \
	--set wifi \
	"${BRACKET_ITEM[@]}" \
	update_freq=30 \
	label.max_chars=16 \
	script="$PLUGIN_DIR/wifi.sh" \
	--subscribe wifi system_woke

sketchybar --add item volume right \
	--set volume \
	"${BRACKET_ITEM[@]}" \
	icon.font="$FONT:Bold:14.0" \
	script="$PLUGIN_DIR/volume.sh" \
	click_script="open -a 'System Settings' /System/Library/PreferencePanes/Sound.prefPane" \
	--subscribe volume volume_change

sketchybar --add item battery right \
	--set battery \
	"${BRACKET_ITEM[@]}" \
	icon.font="$FONT:Bold:14.0" \
	script="$PLUGIN_DIR/battery.sh" \
	--subscribe battery power_source_change system_woke

sketchybar --add item calendar right \
	--set calendar \
	"${BRACKET_ITEM[@]}" \
	icon.font="$FONT:Black:12.0" \
	label.width=45 \
	label.align=right \
	update_freq=30 \
	script="$PLUGIN_DIR/calendar.sh" \
	--subscribe calendar system_woke

sketchybar --add bracket status cpu memory disk wifi volume battery calendar \
	--set status \
	background.color="$BACKGROUND_1" \
	background.border_color="$BACKGROUND_2" \
	background.border_width=1 \
	background.corner_radius=6 \
	background.height=26 \
	background.padding_left=4 \
	background.padding_right=4
