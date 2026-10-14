#!/usr/bin/env bash

declare -A device_to_card

while true; do
    device_to_card=()

    # Get list of paired devices
    mapfile -t mac_adressess < <(bluetoothctl devices | awk '{print $2}')

    # Build options
    options=""
    line_count=0

    for mac in "${mac_adressess[@]}"; do
            info=$(bluetoothctl info "$mac")
        device_name=$(echo "$info" | grep "Name:" | cut -d' ' -f2-)

        # Check connection status
        if echo "$info" | grep -q "Connected: yes"; then
            status="🟢"
        elif echo "$info" | grep -q "Paired: yes"; then
            status="⚪"
        else
            status="⚫"
        fi

        options+="Device:  $status $device_name\n"
        ((line_count++))

        # If device is connected, show profiles
        if echo "$info" | grep -q "Connected: yes"; then
            card_info=$(pactl -f json list cards | jq -r --arg name "$device_name" '.[] | select(.properties."device.description" | contains($name))')

            if [[ -n "$card_info" ]]; then
                current_profile=$(echo "$card_info" | jq -r '.active_profile')
                # echo "Current profile: $current_profile"
                card_name=$(echo "$card_info" | jq -r '.name')
                device_to_card["$device_name"]="$card_name"
                mapfile -t profiles < <(echo "$card_info" | jq -r '.profiles | keys[]')
                # echo "Available profiles: ${profiles[*]}"

                for profile in "${profiles[@]}"; do
                    # Skip "off" profile
                    [[ "$profile" == "off" ]] && continue

                    mark="  "
                    [[ "$profile" == "$current_profile" ]] && mark="🟢"

                    options+="Profile: ${mark}|${device_name}|${profile}\n"
                    ((line_count++))
                done
            fi
        fi
    done

    chosen=$(echo -e "$options" | rofi -dmenu -p "Bluetooth" \
        -theme-str 'window { location: northeast; anchor: northeast; x-offset: -10px; y-offset: 10px; width: 700px; }' \
        -theme-str 'listview { lines: '$line_count';  }' \
        -theme-str 'inputbar { enabled: false; }' \
        -theme-str 'mainbox { children: [ listview ]; }')

    # Esc / cancel / click outside exits
    if [[ -z "$chosen" ]]; then
        exit 0
    fi

    if [[ "$chosen" == "Device:"* ]]; then
        device_name=$(echo "$chosen" | sed 's/Device:  [🟢⚪⚫] \(.*\)/\1/')

        echo "Toggling connection for device: $device_name"

        for mac in "${mac_adressess[@]}"; do
            info=$(bluetoothctl info "$mac")
            name=$(echo "$info" | grep "Name:" | cut -d' ' -f2-)

            if [[ "$name" == "$device_name" ]]; then
                if echo "$info" | grep -q "Connected: yes"; then
                    bluetoothctl disconnect "$mac"
                else
                    bluetoothctl connect "$mac"
                    # Wait (max ~2s) for the audio card so profiles show up on the next render
                    for _ in {1..8}; do
                        pactl list cards short | grep -qi "bluez_card.${mac//:/_}" && break
                        sleep 0.25
                    done
                fi
                break
            fi
        done
    elif [[ "$chosen" == "Profile:"* ]]; then
        # Profile selection
        device_name=$(echo "$chosen" | cut -d'|' -f2)
        profile=$(echo "$chosen" | cut -d'|' -f3)
        card_name=${device_to_card["$device_name"]}
        echo "Setting profile $profile for card $card_name (of device $device_name)"
        pactl set-card-profile "$card_name" "$profile"
        # pkill -RTMIN+9 waybar
    fi
done
