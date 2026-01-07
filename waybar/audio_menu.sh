#!/usr/bin/env bash

# List all sinks
sinks=($(pactl list short sinks | awk '{print $2}'))

# Get sink descriptions
sink_descs=()
for s in "${sinks[@]}"; do
    desc=$(pactl list sinks | awk -v sink="$s" '/^Sink #/ {found=0} $0 ~ sink {found=1} found && /Description:/ {print substr($0, index($0,$3)); exit}')
    sink_descs+=("$desc")
done

# Get default sink
default_sink=$(pactl get-default-sink)

# Build menu
options=""
for i in "${!sinks[@]}"; do
    mark=""
    [[ "${sinks[$i]}" == "$default_sink" ]] && mark="[current] "
    options+="$mark${sink_descs[$i]}\n"
done
options+="────────────\nCancel"

chosen=$(echo -e "$options" | rofi -dmenu -p "Select Audio Output" \
    -theme-str 'window { location: northeast; anchor: northeast; x-offset: -10px; y-offset: 10px; width: 350px; }' \
    -theme-str 'listview { lines: 10; }' \
    -theme-str 'inputbar { enabled: false; }' \
    -theme-str 'mainbox { children: [ listview ]; }')

# Set sink if selected
for i in "${!sink_descs[@]}"; do
    if [[ "$chosen" == *"${sink_descs[$i]}"* ]]; then
        pactl set-default-sink "${sinks[$i]}"
        exit 0
    fi
done
