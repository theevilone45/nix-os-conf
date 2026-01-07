#!/usr/bin/env bash

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
    
    options+="Device: $status $device_name\n"
    ((line_count++))
    
    # If device is connected, show profiles
    if echo "$info" | grep -q "Connected: yes"; then
        card_info=$(pactl -f json list cards | jq -r --arg name "$device_name" '.[] | select(.properties."device.description" | contains($name))')
        
        if [[ -n "$card_info" ]]; then
            current_profile=$(echo "$card_info" | jq -r '.active_profile')
            # echo "Current profile: $current_profile"
            card_name=$(echo "$card_info" | jq -r '.name')
            mapfile -t profiles < <(echo "$card_info" | jq -r '.profiles | keys[]')
            # echo "Available profiles: ${profiles[*]}"
            
            for profile in "${profiles[@]}"; do
                # Skip "off" profile
                [[ "$profile" == "off" ]] && continue
                
                mark="  "
                [[ "$profile" == "$current_profile" ]] && mark="▶ "
                
                options+="Profile: ${mark}|${device_name}|${profile}\n"
                ((line_count++))
            done
        fi
    fi 

    # profiles=$(pactl -f json list cards | jq -r '.[] | select(.properties."device.description"=="WH-CH720N") | ( .active_profile, (.profiles | keys[]))')

    # echo "Profiles: $profiles"
    
    # # Check connection status
    # if echo "$info" | grep -q "Connected: yes"; then
    #     status="🟢"
    # elif echo "$info" | grep -q "Paired: yes"; then
    #     status="⚪"
    # else
    #     status="⚫"
    # fi
    
    # options+="$status $name|$mac\n"
done

echo "Profile to device mapping:"
for key in "${!profile_to_device[@]}"; do
    echo "$key => ${profile_to_device[$key]}"
done

chosen=$(echo -e "$options" | rofi -dmenu -p "Bluetooth" \
    -theme-str 'window { location: northeast; anchor: northeast; x-offset: -10px; y-offset: 10px; width: 400px; }' \
    -theme-str 'listview { lines: '$line_count';  }' \
    -theme-str 'inputbar { enabled: false; }' \
    -theme-str 'mainbox { children: [ listview ]; }')

if [[ "$chosen" == *"Device"* ]]; then
    device_name=$(echo "$chosen" | sed 's/Device: [🟢⚪⚫] \(.*\)/\1/')

    echo "Toggling connection for device: $device_name"
    
    for mac in "${mac_adressess[@]}"; do
        info=$(bluetoothctl info "$mac")
        name=$(echo "$info" | grep "Name:" | cut -d' ' -f2-)
        
        if [[ "$name" == "$device_name" ]]; then
            if echo "$info" | grep -q "Connected: yes"; then
                bluetoothctl disconnect "$mac"
            else
                bluetoothctl connect "$mac"
            fi
            exit 0
        fi
    done
fi

if [[ "$chosen" == *"Profile"* ]]; then
    # Profile selection
    card_name=$(echo "$chosen" | cut -d'|' -f3)
    profile=$(echo "$chosen" | cut -d'|' -f4)
    pactl set-card-profile "$card_name" "$profile"
    pkill -RTMIN+9 waybar
fi
# else
#     # Device connection toggle
#     for mac in "${mac_adressess[@]}"; do
#         info=$(bluetoothctl info "$mac")
#         name=$(echo "$info" | grep "Name:" | cut -d' ' -f2-)
#         
#         if [[ "$chosen" == *"$name"* ]]; then
#             if echo "$info" | grep -q "Connected: yes"; then
#                 bluetoothctl disconnect "$mac"
#             else
#                 bluetoothctl connect "$mac"
#             fi
#             exit 0
#         fi
#     done
# fi

# # Show menu
# chosen=$(echo -e "$options" | rofi -dmenu -p "Bluetooth" \
#     -theme-str 'window { location: northeast; anchor: northeast; x-offset: -10px; y-offset: 10px; width: 350px; }' \
#     -theme-str 'listview { lines: '${#mac_adressess[@]}'; }' \
#     -theme-str 'inputbar { enabled: false; }' \
#     -theme-str 'mainbox { children: [ listview ]; }')

# # Extract MAC from choice
# for mac in "${mac_adressess[@]}"; do
#     if [[ "$chosen" == *"$mac"* ]]; then
#         # Toggle connection
#         info=$(bluetoothctl info "$mac")
#         if echo "$info" | grep -q "Connected: yes"; then
#             bluetoothctl disconnect "$mac"
#         else
#             bluetoothctl connect "$mac"
#         fi
#         exit 0
#     fi
# done
