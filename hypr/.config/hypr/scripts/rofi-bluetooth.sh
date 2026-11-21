#!/usr/bin/env bash
#
# Rofi Bluetooth Menu for Hyprland (Nyverune Rice)
#

notify() {
    notify-send -a "Bluetooth" -i bluetooth "$1" "$2" 2>/dev/null
}

# Check Bluetooth Power
POWER_STATE=$(bluetoothctl show | grep "Powered: yes")

if [ -n "$POWER_STATE" ]; then
    POWER_OPT="󰂲  Disable Bluetooth"
    
    # Paired devices
    DEVICES=$(bluetoothctl paired-devices | while read -r _ mac name; do
        INFO=$(bluetoothctl info "$mac")
        CONNECTED=$(echo "$INFO" | grep "Connected: yes")
        BATTERY=$(echo "$INFO" | grep "Battery Percentage" | awk '{print $4}' | tr -d '()')
        
        if [ -n "$CONNECTED" ]; then
            STATUS="󰄬 [Connected"
            [ -n "$BATTERY" ] && STATUS="$STATUS • $BATTERY%"
            STATUS="$STATUS]"
        else
            STATUS=""
        fi
        echo -e "󰂱  $name ($mac)\t$STATUS"
    done)
    
    OPTIONS="$POWER_OPT\n󰑐  Scan for Devices\n$DEVICES"
else
    POWER_OPT="󰂯  Enable Bluetooth"
    OPTIONS="$POWER_OPT"
fi

CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "󰂯 Bluetooth" -theme-str 'window {width: 480px;} listview {lines: 8;}')

if [ -z "$CHOSEN" ]; then
    exit 0
fi

case "$CHOSEN" in
    "󰂲  Disable Bluetooth")
        bluetoothctl power off
        notify "Bluetooth" "Bluetooth powered off"
        ;;
    "󰂯  Enable Bluetooth")
        bluetoothctl power on
        notify "Bluetooth" "Bluetooth powered on"
        ;;
    "󰑐  Scan for Devices")
        notify "Bluetooth" "Scanning for 8 seconds..."
        bluetoothctl --timeout 8 scan on >/dev/null 2>&1
        exec "$0"
        ;;
    *)
        MAC=$(echo "$CHOSEN" | grep -oE '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}')
        NAME=$(echo "$CHOSEN" | awk -F'\t' '{print $1}' | sed 's/^󰂱 *//')
        
        if [ -n "$MAC" ]; then
            INFO=$(bluetoothctl info "$MAC")
            if echo "$INFO" | grep -q "Connected: yes"; then
                ACTION=$(echo -e "󰂲  Disconnect\n󰆴  Forget/Remove" | rofi -dmenu -p "$NAME" -theme-str 'window {width: 320px;}')
                if [ "$ACTION" = "󰂲  Disconnect" ]; then
                    bluetoothctl disconnect "$MAC"
                    notify "Bluetooth" "Disconnected from $NAME"
                elif [ "$ACTION" = "󰆴  Forget/Remove" ]; then
                    bluetoothctl remove "$MAC"
                    notify "Bluetooth" "Removed $NAME"
                fi
            else
                ACTION=$(echo -e "󰂱  Connect\n󰆴  Forget/Remove" | rofi -dmenu -p "$NAME" -theme-str 'window {width: 320px;}')
                if [ "$ACTION" = "󰂱  Connect" ]; then
                    notify "Bluetooth" "Connecting to $NAME..."
                    if bluetoothctl connect "$MAC"; then
                        notify "Bluetooth" "Connected to $NAME"
                    else
                        notify "Bluetooth" "Failed to connect to $NAME"
                    fi
                elif [ "$ACTION" = "󰆴  Forget/Remove" ]; then
                    bluetoothctl remove "$MAC"
                    notify "Bluetooth" "Removed $NAME"
                fi
            fi
        fi
        ;;
esac
