#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

CORES="$(sysctl -n hw.ncpu 2>/dev/null)"
[ -z "$CORES" ] && CORES=1

CPU="$(ps -A -o %cpu 2>/dev/null | awk -v cores="$CORES" 'NR>1 {s+=$1} END {printf "%.0f", s/cores}')"
[ -z "$CPU" ] && exit 0

COLOR="$LABEL_COLOR"
case $CPU in
[8-9][0-9]|100) COLOR="$RED" ;;
[6-7][0-9]) COLOR="$ORANGE" ;;
esac

sketchybar --set "$NAME" icon="$ICON_CPU" icon.color="$COLOR" label="${CPU}%"
