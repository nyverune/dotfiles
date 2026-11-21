#!/usr/bin/env bash
#
# Rofi Wi-Fi Menu for Hyprland (Nyverune Rice)
#

# Ensure notify-send or mako works
notify() {
    notify-send -a "Wi-Fi" -i network-wireless "$1" "$2" 2>/dev/null
}

# Check Wi-Fi state
WIFI_STATE=$(nmcli -fields WIFI g 2>/dev/null | sed '1d' | tr -d ' ')

if [ "$WIFI_STATE" = "enabled" ]; then
    TOGGLE="󰖪  Disable Wi-Fi"
else
    TOGGLE="󰖩  Enable Wi-Fi"
fi

# Scan and list networks using terse output to preserve spaces in SSIDs
declare -A SEEN_SSIDS
NETWORKS=$(nmcli -t -f "IN-USE,SSID,BARS,SECURITY" device wifi list 2>/dev/null | while IFS=: read -r inuse ssid bars sec; do
    [ -z "$ssid" ] && continue
    [ "$ssid" = "--" ] && continue
    
    # Avoid duplicate SSIDs from dual-band or mesh APs (nmcli lists strongest first)
    if [ -n "${SEEN_SSIDS[$ssid]}" ]; then
        continue
    fi
    SEEN_SSIDS["$ssid"]=1
    
    if [ "$inuse" = "*" ]; then
        STATUS="󰄬 [Connected]"
    else
        STATUS=""
    fi
    
    if [ -n "$sec" ] && [ "$sec" != "--" ]; then
        LOCK="󰌾"
    else
        LOCK=" "
    fi
    
    echo -e "󰤨  $ssid\t$bars $LOCK $STATUS"
done)

# Present in Rofi
CHOSEN=$(echo -e "$TOGGLE\n󰑐  Rescan\n$NETWORKS" | rofi -dmenu -i -p "󰤨 Wi-Fi" -theme-str 'window {width: 500px;} entry {placeholder: "Search networks...";} listview {lines: 8;}')

if [ -z "$CHOSEN" ]; then
    exit 0
fi

case "$CHOSEN" in
    "󰖪  Disable Wi-Fi")
        nmcli radio wifi off
        notify "Wi-Fi" "Wi-Fi adapter disabled"
        ;;
    "󰖩  Enable Wi-Fi")
        nmcli radio wifi on
        notify "Wi-Fi" "Wi-Fi adapter enabled"
        ;;
    "󰑐  Rescan")
        nmcli device wifi rescan
        notify "Wi-Fi" "Scanning for available networks..."
        sleep 1
        exec "$0"
        ;;
    *)
        # Extract clean SSID
        SELECTED_SSID=$(echo "$CHOSEN" | awk -F'\t' '{print $1}' | sed 's/^󰤨 *//' | sed 's/ *$//')
        
        if [ -z "$SELECTED_SSID" ]; then
            exit 0
        fi

        # Check if already saved / known connection
        KNOWN=$(nmcli -g NAME connection show | grep "^$SELECTED_SSID$")

        if [ -n "$KNOWN" ]; then
            notify "Wi-Fi" "Connecting to $SELECTED_SSID..."
            if nmcli connection up "$SELECTED_SSID"; then
                notify "Wi-Fi" "Successfully connected to $SELECTED_SSID"
            else
                notify "Wi-Fi" "Failed to connect to $SELECTED_SSID"
            fi
        else
            # Check security
            IS_SECURE=$(echo "$CHOSEN" | grep "󰌾")
            if [ -n "$IS_SECURE" ]; then
                PASS=$(rofi -dmenu -password -p "Password for $SELECTED_SSID" -theme-str 'window {width: 380px;} entry {placeholder: "Enter password...";}')
                if [ -n "$PASS" ]; then
                    notify "Wi-Fi" "Connecting to $SELECTED_SSID..."
                    if nmcli device wifi connect "$SELECTED_SSID" password "$PASS"; then
                        notify "Wi-Fi" "Connected to $SELECTED_SSID"
                    else
                        notify "Wi-Fi" "Failed to connect to $SELECTED_SSID"
                    fi
                fi
            else
                notify "Wi-Fi" "Connecting to open network $SELECTED_SSID..."
                nmcli device wifi connect "$SELECTED_SSID"
            fi
        fi
        ;;
esac
