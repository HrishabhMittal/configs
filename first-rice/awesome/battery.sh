#!/bin/bash

# Temporary files to track alerts
low_battery_alert_file="/tmp/battery_low_alert.shown.inawesome"
high_battery_alert_file="/tmp/battery_high_alert.shown.inawesome"

# Get the battery information
battery_info=$(upower -i $(upower -e | grep BAT))
percentage=$(echo "$battery_info" | grep -oP 'percentage:\s+\K\d+')
state=$(echo "$battery_info" | grep -oP 'state:\s+\K\w+')

# Check if battery percentage is less than 10 and not charging
if [[ "$percentage" -lt 10 && "$state" != "charging" ]]; then 
    # Check if the low battery alert has already been shown
    if [[ ! -f "$low_battery_alert_file" ]]; then
        yad --info --title "Battery Low!" --text "Battery is less than 10%. Please plug in the charger."
        touch "$low_battery_alert_file"  # Create the low battery alert file
    fi
else
    # If battery is above 10 or charging, remove the low battery alert file
    if [[ -f "$low_battery_alert_file" ]]; then
        rm "$low_battery_alert_file"
    fi
fi

# Check if battery percentage is above 85 and still charging
if [[ "$percentage" -gt 85 && "$state" == "charging" ]]; then 
    # Check if the high battery alert has already been shown
    if [[ ! -f "$high_battery_alert_file" ]]; then
        yad --info --title "Battery High!" --text "Battery is above 85%. Consider unplugging the charger."
        touch "$high_battery_alert_file"  # Create the high battery alert file
    fi
else
    # If battery is 85 or below or not charging, remove the high battery alert file
    if [[ -f "$high_battery_alert_file" ]]; then
        rm "$high_battery_alert_file"
    fi
fi
