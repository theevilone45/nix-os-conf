#!/usr/bin/env bash

# Get default sink
sink=$(pactl get-default-sink)

# Get volume and mute status
vol=$(pactl get-sink-volume "$sink" | grep -oP '\d+%' | head -1 | tr -d '%')
mute=$(pactl get-sink-mute "$sink" | grep -oP 'yes|no')

# Get sink description
sink_desc=$(pactl list sinks | awk -v s="$sink" '/^Sink #/ {found=0} $0 ~ s {found=1} found && /Description:/ {print substr($0, index($0,$3)); exit}')

# Set icon and class
if [[ "$mute" == "yes" ]]; then
    icon="🔇"
    class="muted"
else
    if (( vol >= 70 )); then icon="🔊"; class="high";
    elif (( vol >= 30 )); then icon="🔉"; class="medium";
    else icon="🔈"; class="low"; fi
fi

# Escape JSON special characters and create tooltip
tooltip=$(printf "%s - %s" "$sink_desc" "$sink" | sed 's/\\/\\\\/g; s/"/\\"/g')

# Output JSON for waybar
printf '{"text":"%s %s%%","tooltip":"%s","class":"%s"}\n' "$icon" "$vol" "$tooltip" "$class"
