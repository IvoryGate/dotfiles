#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

TOTAL=$(( $(sysctl -n hw.memsize 2>/dev/null) / 1073741824 ))
[ "$TOTAL" -eq 0 ] && exit 0

USED_MB="$(top -l 1 -s 0 2>/dev/null | awk '/PhysMem/ {gsub(/M,/,"",$2); print $2; exit}')"
[ -z "$USED_MB" ] && exit 0

USED_G="$(awk -v mb="$USED_MB" 'BEGIN {printf "%.1f", mb / 1024}')"
PERCENT="$(awk -v mb="$USED_MB" -v total="$TOTAL" 'BEGIN {printf "%d", (mb / 1024) / total * 100}')"

COLOR="$LABEL_COLOR"
case $PERCENT in
[8-9][0-9]|100) COLOR="$RED" ;;
[6-7][0-9]) COLOR="$ORANGE" ;;
esac

sketchybar --set "$NAME" icon="$ICON_MEMORY" icon.color="$COLOR" label="${USED_G}/${TOTAL}G"
