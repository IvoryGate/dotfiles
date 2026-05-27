#!/usr/bin/env bash

if [ "$SENDER" = "front_app_switched" ] && [ -n "$INFO" ]; then
	LABEL="$INFO"
else
	LABEL="${INFO:-$("$CONFIG_DIR/helpers/front_app_helper" 2>/dev/null)}"
fi

[ -z "$LABEL" ] && exit 0

ICON="$("$CONFIG_DIR/plugins/icon_map.sh" "$LABEL")"
sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
