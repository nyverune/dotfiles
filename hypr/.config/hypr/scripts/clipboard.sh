#!/usr/bin/env bash
# ===============================================
# Nyverune Clipboard Manager (Rofi + Cliphist)
# ===============================================

export PATH="$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:/usr/bin:$PATH"

case "$1" in
    delete)
        cliphist list | rofi -dmenu -p "󰅖 Delete" -mesg "Select item to remove from clipboard" | cliphist delete
        ;;
    wipe)
        cliphist wipe
        notify-send -a "Clipboard" -u low "Portapapeles" "Historial vaciado correctamente."
        ;;
    *)
        selection=$(cliphist list | rofi -dmenu -p "󰅌 Clipboard" -mesg "Select entry to copy to clipboard")
        if [ -n "$selection" ]; then
            echo "$selection" | cliphist decode | wl-copy
            notify-send -a "Clipboard" -u low -t 2000 "Portapapeles" "Elemento copiado al portapapeles."
        fi
        ;;
esac
