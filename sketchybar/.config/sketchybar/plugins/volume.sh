#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

PERCENTAGE="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"

case $PERCENTAGE in
[6-9][0-9]|100) ICON="$ICON_VOLUME_100" ;;
[3-5][0-9]) ICON="$ICON_VOLUME_66" ;;
[1-2][0-9]) ICON="$ICON_VOLUME_33" ;;
[1-9]) ICON="$ICON_VOLUME_10" ;;
0) ICON="$ICON_VOLUME_MUTE" ;;
*) ICON="$ICON_VOLUME_100" ;;
esac

if [ "$SENDER" = "volume_change" ]; then
	PERCENTAGE="$INFO"
	case $PERCENTAGE in
	[6-9][0-9]|100) ICON="$ICON_VOLUME_100" ;;
	[3-5][0-9]) ICON="$ICON_VOLUME_66" ;;
	[1-2][0-9]) ICON="$ICON_VOLUME_33" ;;
	[1-9]) ICON="$ICON_VOLUME_10" ;;
	0) ICON="$ICON_VOLUME_MUTE" ;;
	*) ICON="$ICON_VOLUME_100" ;;
	esac
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
