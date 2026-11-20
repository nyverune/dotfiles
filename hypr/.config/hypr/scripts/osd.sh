#!/usr/bin/env bash
# ===============================================
# Nyverune OSD Controller (Volume, Mic & Brightness)
# Communicates seamlessly with Quickshell OSD via FIFO/file and IPC
# ===============================================

OSD_FILE="/tmp/nyverune-osd"

get_volume() {
    local out
    out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    local vol
    vol=$(echo "$out" | awk '{print int($2 * 100)}')
    echo "${vol:-0}"
}

is_volume_muted() {
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q "MUTED"; then
        echo "true"
    else
        echo "false"
    fi
}

get_brightness() {
    local b
    b=$(brightnessctl -m 2>/dev/null | head -n1 | cut -d, -f4 | tr -d '%')
    echo "${b:-0}"
}

is_mic_muted() {
    if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q "MUTED"; then
        echo "true"
    else
        echo "false"
    fi
}

ACTION="$1"
VALUE="$2"
TOKEN=$(date +%s%N)

case "$ACTION" in
    volume)
        if [ "$VALUE" = "mute" ]; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        else
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$VALUE"
        fi

        VOL=$(get_volume)
        MUTED=$(is_volume_muted)

        if [ "$MUTED" = "true" ] || [ "$VOL" -eq 0 ]; then
            ICON="󰝟"
        elif [ "$VOL" -lt 33 ]; then
            ICON=""
        elif [ "$VOL" -lt 66 ]; then
            ICON=""
        else
            ICON=""
        fi

        # 1. Append to listener file
        printf '{"type":"volume","value":%d,"icon":"%s","muted":%s,"ts":%s}\n' \
            "$VOL" "$ICON" "$MUTED" "$TOKEN" >> "$OSD_FILE"
        # 2. Direct IPC call as fast fallback
        quickshell ipc call osd trigger "volume" "$VOL" "$ICON" "$MUTED" >/dev/null 2>&1 &
        ;;

    brightness)
        brightnessctl set "$VALUE" >/dev/null 2>&1
        BRIGHT=$(get_brightness)

        if [ "$BRIGHT" -lt 33 ]; then
            ICON="󰃞"
        elif [ "$BRIGHT" -lt 66 ]; then
            ICON="󰃟"
        else
            ICON="󰃠"
        fi

        printf '{"type":"brightness","value":%d,"icon":"%s","muted":false,"ts":%s}\n' \
            "$BRIGHT" "$ICON" "$TOKEN" >> "$OSD_FILE"
        quickshell ipc call osd trigger "brightness" "$BRIGHT" "$ICON" "false" >/dev/null 2>&1 &
        ;;

    mic)
        if [ "$VALUE" = "mute" ] || [ -z "$VALUE" ]; then
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        fi

        MUTED=$(is_mic_muted)

        if [ "$MUTED" = "true" ]; then
            ICON="󰍭"
        else
            ICON="󰍬"
        fi

        printf '{"type":"mic","value":0,"icon":"%s","muted":%s,"ts":%s}\n' \
            "$ICON" "$MUTED" "$TOKEN" >> "$OSD_FILE"
        quickshell ipc call osd trigger "mic" "0" "$ICON" "$MUTED" >/dev/null 2>&1 &
        ;;

    *)
        echo "Usage: $0 {volume [5%+|5%-|mute]|brightness [5%+|5%-]|mic [mute]}"
        exit 1
        ;;
esac
