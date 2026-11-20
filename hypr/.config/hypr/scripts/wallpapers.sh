#!/usr/bin/env bash
# ===============================================
# Nyverune Wallpaper Selector (Quickshell Wallpaper Picker)
# ===============================================

QS_PICKER="$HOME/.local/share/qs-wallpaper-picker/scripts/open_picker.sh"

if [ -x "$QS_PICKER" ]; then
    exec "$QS_PICKER" "$@"
fi
