#!/usr/bin/env bash
# ===============================================
# Nyverune Battery Status Indicator for Hyprlock / Scripts
# ===============================================

cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)
if [ -z "$cap" ]; then
    echo "󰂄 100%"
    exit 0
fi

stat=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1)

if [ "$stat" = "Charging" ]; then
    icon="󰂄"
elif [ "$cap" -ge 90 ]; then
    icon="󰁹"
elif [ "$cap" -ge 70 ]; then
    icon="󰂀"
elif [ "$cap" -ge 50 ]; then
    icon="󰁾"
elif [ "$cap" -ge 30 ]; then
    icon="󰁼"
elif [ "$cap" -ge 15 ]; then
    icon="󰁺"
else
    icon="󰂃"
fi

echo "$icon  $cap%"
