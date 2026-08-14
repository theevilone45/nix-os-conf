#!/usr/bin/env bash

while true; do
    # List all sinks
    mapfile -t sinks < <(pactl list short sinks | awk '{print $2}')

    # Get device names
    mapfile -t devices < <(
        pactl list sinks | awk -F'"' '/device.description =/ { print $2 }'
    )

    current_sink=$(pactl get-default-sink)

    options=""
    for i in "${!sinks[@]}"; do
        mark=""
        if [[ "${sinks[$i]}" == "$current_sink" ]]; then
            mark="🟢"
        fi
        options+="$mark ${devices[$i]}\n"
    done

    chosen=$(echo -e "$options" | rofi -dmenu -p "Select Audio Output" \
        -theme-str 'window { location: northeast; anchor: northeast; x-offset: -10px; y-offset: 10px; width: 700px; }' \
        -theme-str "listview { lines: ${#sinks[@]}; }" \
        -theme-str 'inputbar { enabled: false; }' \
        -theme-str 'mainbox { children: [ listview ]; }')

    # Esc / cancel / click outside exits
    if [[ -z "$chosen" ]]; then
        exit 0
    fi

    for i in "${!devices[@]}"; do
        if [[ "$chosen" == *"${devices[$i]}"* ]]; then
            echo "Setting default sink to ${sinks[$i]}"
            pactl set-default-sink "${sinks[$i]}"

            # Move all existing sink inputs to the new sink
            pactl list short sink-inputs | while read -r stream; do
                stream_id=$(echo "$stream" | cut -f1)
                pactl move-sink-input "$stream_id" "${sinks[$i]}" 2>/dev/null
            done

            pkill -RTMIN+8 waybar
            break
        fi
    done
done
