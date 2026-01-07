#!/usr/bin/env bash

# Audio menu using yad with actual slider
# Styled to match dark theme

# Get current volume percentage
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%'
}

# Get mute status
get_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -oP 'yes|no'
}

current_vol=$(get_volume)
mute_status=$(get_mute)
mute_checked=$([[ "$mute_status" == "yes" ]] && echo "TRUE" || echo "FALSE")

# Calculate position (top-right corner)
# Adjust these values based on your screen resolution and waybar height
screen_width=$(xdpyinfo 2>/dev/null | grep dimensions | awk '{print $2}' | cut -d'x' -f1 || echo 1920)
pos_x=$((screen_width - 270))
pos_y=40

result=$(yad --form \
    --title="Audio" \
    --width=250 \
    --height=150 \
    --undecorated \
    --skip-taskbar \
    --on-top \
    --posx="$pos_x" \
    --posy="$pos_y" \
    --field="Volume:SCL" "$current_vol!0..100!1" \
    --field="Mute:CHK" "$mute_checked" \
    --field="Open Mixer:BTN" "pavucontrol &" \
    --button="Apply:0" \
    --button="Close:1" \
    2>/dev/null)

exit_code=$?

if [[ $exit_code -eq 0 && -n "$result" ]]; then
    # Parse result (format: "volume|mute|")
    new_vol=$(echo "$result" | cut -d'|' -f1)
    new_mute=$(echo "$result" | cut -d'|' -f2)
    
    # Apply volume
    pactl set-sink-volume @DEFAULT_SINK@ "${new_vol}%"
    
    # Apply mute
    if [[ "$new_mute" == "TRUE" ]]; then
        pactl set-sink-mute @DEFAULT_SINK@ 1
    else
        pactl set-sink-mute @DEFAULT_SINK@ 0
    fi
fi
