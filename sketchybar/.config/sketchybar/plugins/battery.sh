#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

battery_icon() {
	local pct="$1"
	local charging="$2"

	if [ "$charging" = "1" ]; then
		case $pct in
		9[0-9] | 100) echo "$ICON_BATTERY_CHARGING_100" ;;
		[7-8][0-9]) echo "$ICON_BATTERY_CHARGING_80" ;;
		[5-6][0-9]) echo "$ICON_BATTERY_CHARGING_50" ;;
		[2-4][0-9]) echo "$ICON_BATTERY_CHARGING_30" ;;
		[1-9]) echo "$ICON_BATTERY_CHARGING_10" ;;
		*) echo "$ICON_BATTERY_CHARGING" ;;
		esac
	else
		case $pct in
		9[0-9] | 100) echo "$ICON_BATTERY_100" ;;
		[7-8][0-9]) echo "$ICON_BATTERY_75" ;;
		[5-6][0-9]) echo "$ICON_BATTERY_50" ;;
		[2-4][0-9]) echo "$ICON_BATTERY_25" ;;
		*) echo "$ICON_BATTERY_0" ;;
		esac
	fi
}

battery_color() {
	local pct="$1"
	local charging="$2"

	if [ "$charging" = "1" ]; then
		echo "$GREEN"
		return
	fi

	case $pct in
	[1-2][0-9]) echo "$ORANGE" ;;
	[0-9]) echo "$RED" ;;
	*) echo "$LABEL_COLOR" ;;
	esac
}

BATT_LINE="$(pmset -g batt 2>/dev/null | grep 'InternalBattery' | tail -1)"
PERCENTAGE="$(echo "$BATT_LINE" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"

[ -z "$PERCENTAGE" ] && exit 0

CHARGING=0
if pmset -g batt 2>/dev/null | grep -qE 'AC Power|AC attached'; then
	CHARGING=1
fi

if ! echo "$BATT_LINE" | grep -qE 'discharging|charging|AC attached'; then
	sketchybar --set "$NAME" drawing=off
	exit 0
fi

ICON="$(battery_icon "$PERCENTAGE" "$CHARGING")"
COLOR="$(battery_color "$PERCENTAGE" "$CHARGING")"

sketchybar --set "$NAME" \
	drawing=on \
	icon="$ICON" \
	icon.color="$COLOR" \
	label="${PERCENTAGE}%"
