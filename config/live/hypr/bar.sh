#!/usr/bin/env bash
BAR_CMD="$HOME/.config/hypr/lemonbar.sh"
BAR_TITLE="bar"
BAR_X=0
BAR_OFF_Y=35

$BAR_CMD &

visible=true
while true; do
    fs=$(hyprctl activewindow -j | jq '.fullscreen') || fs=0
    if [[ "$fs" -eq 0 ]]; then
        if [[ "$visible" == false ]]; then
            echo off
            hyprctl dispatch movewindowpixel $BAR_X $BAR_OFF_Y, "title:^($BAR_TITLE)$" &> /dev/null
            visible=true
        fi
    elif [[ "$visible" == true ]]; then
        echo on
        hyprctl dispatch movewindowpixel $BAR_X -$BAR_OFF_Y, "title:^($BAR_TITLE)$" &> /dev/null
        visible=false
    fi
    sleep 0.2
done
