#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

STATE=$(python3 -c 'import json,sys; d=json.loads(sys.argv[1]); print(d.get("state",""))' "$INFO" 2>/dev/null)

if [ "$STATE" = "playing" ]; then
	TITLE=$(python3 -c 'import json,sys; d=json.loads(sys.argv[1]); t=d.get("title",""); a=d.get("artist",""); print(f"{t} — {a}" if a else t)' "$INFO" 2>/dev/null)
	sketchybar --set "$NAME" icon="$ICON_MEDIA" icon.color="$ACCENT" label="$TITLE" label.color="$LABEL_COLOR" drawing=on
elif [ "$STATE" = "paused" ]; then
	TITLE=$(python3 -c 'import json,sys; d=json.loads(sys.argv[1]); t=d.get("title",""); a=d.get("artist",""); print(f"{t} — {a}" if a else t)' "$INFO" 2>/dev/null)
	sketchybar --set "$NAME" icon="$ICON_MEDIA_PAUSE" icon.color="$MUTED" label="$TITLE" label.color="$MUTED" drawing=on
else
	sketchybar --set "$NAME" drawing=off
fi
