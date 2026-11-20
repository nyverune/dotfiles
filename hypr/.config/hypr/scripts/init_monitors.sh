#!/usr/bin/env bash

# Wait for Hyprland session startup to complete
sleep 1

# Check if external HDMI-A-1 monitor is connected
if hyprctl monitors | grep -q "HDMI-A-1"; then
    # Dual Monitor setup:
    hyprctl dispatch 'hl.dsp.focus({ monitor = "eDP-1" })'
    hyprctl dispatch 'hl.dsp.focus({ workspace = 10 })'
    hyprctl dispatch 'hl.dsp.focus({ monitor = "HDMI-A-1" })'
    hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'
else
    # Single Monitor setup (integrated eDP-1 display only):
    # - Start on workspace 1
    hyprctl dispatch 'hl.dsp.focus({ monitor = "eDP-1" })'
    hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'
fi