#!/usr/bin/env bash

# Rofi power menu matching Waybar style

options="Shutdown\nReboot"

chosen=$(echo -e "$options" | rofi -dmenu -p "Power" \
    -theme-str 'window { location: northeast; anchor: northeast; x-offset: -10px; y-offset: 10px; width: 200px; }' \
    -theme-str 'listview { lines: 2; }' \
    -theme-str 'inputbar { enabled: false; }' \
    -theme-str 'mainbox { children: [ listview ]; }')

case "$chosen" in
    "Shutdown")
        shutdown now
        ;;
    "Reboot")
        reboot
        ;;
esac
