#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

SSID=""
IFACE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')"

if [ -n "$IFACE" ]; then
	SSID="$(networksetup -getairportnetwork "$IFACE" 2>/dev/null | awk -F': ' 'NF > 1 {print $2}')"
fi

if [ -n "$SSID" ] && [ "$SSID" != "You are not associated with an AirPort network." ]; then
	sketchybar --set "$NAME" icon="$ICON_WIFI" icon.color="$ACCENT" label="$SSID"
elif [ -n "$IFACE" ] && ipconfig getifaddr "$IFACE" >/dev/null 2>&1; then
	case "$IFACE" in
	en0) sketchybar --set "$NAME" icon="$ICON_WIFI" icon.color="$ACCENT" label="Wi-Fi" ;;
	en*) sketchybar --set "$NAME" icon="$ICON_ETHERNET" icon.color="$GREEN" label="Ethernet" ;;
	*) sketchybar --set "$NAME" icon="$ICON_ETHERNET" icon.color="$GREEN" label="$IFACE" ;;
	esac
else
	sketchybar --set "$NAME" icon="$ICON_WIFI_OFF" icon.color="$MUTED" label="offline"
fi
