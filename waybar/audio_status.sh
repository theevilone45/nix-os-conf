#!/usr/bin/env bash

# Get default sink
sink=$(pactl get-default-sink)

# Get volume and mute status
vol=$(pactl get-sink-volume "$sink" | grep -oP '\d+%' | head -1 | tr -d '%')
mute=$(pactl get-sink-mute "$sink" | grep -oP 'yes|no')

# Get sink description
sink_desc=$(pactl list sinks | awk -v s="$sink" '/^Sink #/ {found=0} $0 ~ s {found=1} found && /Description:/ {print substr($0, index($0,$3)); exit}')

# Escape JSON special characters and create tooltip
tooltip=$(printf "%s - %s" "$sink_desc" "$sink" | sed 's/\\/\\\\/g; s/"/\\"/g')

# Output JSON for waybar
printf '{"text":"Audio %s%%","tooltip":"%s"}\n' "$vol" "$tooltip"
