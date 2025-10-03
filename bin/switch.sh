#!/bin/bash

TMP_FILE="/tmp/wallpaper-switch.temp"

if [[ -f "$TMP_FILE" ]]; then
    rm "$TMP_FILE"
    killall hyprpaper
    mpvpaper eDP-1 /home/hrishabhmittal/.config/hypr/wall.mp4 -o "loop no-audio" --fork
else
    touch "$TMP_FILE"
    killall mpvpaper
    hyprpaper &> /dev/null & disown
fi
