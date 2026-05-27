#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

read -r AVAIL PERCENT <<EOF
$(df -h /System/Volumes/Data 2>/dev/null | awk 'NR==2 {gsub(/i$/, "", $4); print $4, $5}' | tr -d '%')
EOF

[ -z "$AVAIL" ] && exit 0

COLOR="$LABEL_COLOR"
case $PERCENT in
[8-9][0-9]|100) COLOR="$RED" ;;
[7][0-9]) COLOR="$ORANGE" ;;
esac

sketchybar --set "$NAME" icon="$ICON_DISK" icon.color="$COLOR" label="$AVAIL"
