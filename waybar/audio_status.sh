#!/usr/bin/env bash

# TODO: pactrl actualy support JSON format, use that instead of parsing text output

sink=$(pactl get-default-sink)

vol=$(pactl get-sink-volume "$sink" | grep -oP '\d+%' | head -1 | tr -d '%')
mute=$(pactl get-sink-mute "$sink" | grep -oP 'yes|no')

sink_desc=$(pactl list sinks | awk -v s="$sink" '/^Sink #/ {found=0} $0 ~ s {found=1} found && /Description:/ {print substr($0, index($0,$3)); exit}')

tooltip=$(printf "%s - %s" "$sink_desc" "$sink" | sed 's/\\/\\\\/g; s/"/\\"/g')

printf '{"text":"Audio %s%%","tooltip":"%s"}\n' "$vol" "$tooltip"
