#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

layout="$(aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null)"

case "$layout" in
floating)
	sketchybar --set "$NAME" icon="$ICON_FLOAT" icon.color="$ORANGE" label="float"
	;;
*)
	sketchybar --set "$NAME" icon="$ICON_TILE" icon.color="$GREEN" label="tile"
	;;
esac
