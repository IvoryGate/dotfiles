#!/usr/bin/env bash

layout="$(aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null)"

if [ "$layout" = "floating" ]; then
	aerospace layout tiling
else
	aerospace layout floating
fi
