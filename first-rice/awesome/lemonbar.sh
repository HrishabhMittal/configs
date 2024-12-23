#!/bin/bash
get_desktops() {    
    awesome-client 'tags = screen[mouse.screen].tags; names = {}; for _, tag in ipairs(tags) do table.insert(names, tag.name) end; return table.concat(names, " ")' | sed 's/^ *string "//' | sed 's/"$//'
}
get_active_tag() {
    awesome-client 'return client.focus and client.focus.screen.selected_tag.name or ""' | sed 's/^ *string "//' | sed 's/"$//'  
}
format_desktops() {
    local desktops=$(get_desktops)
    local active_tag=$(get_active_tag)
    local output=""
    for tag in $desktops; do
        if [[ "$tag" == "$active_tag" ]]; then
            output+="● "
        else
            output+="○ "  
        fi
    done
    echo "$output"
}
Clock() {
    DATETIME=$(date "+%a %-d %b, %-l:%M %p")
    echo -e -n "${DATETIME}"
}
User() {
    echo -n $USER@$HOSTNAME
}
Cpu() {
    c=$(top -bn1 | grep "Cpu(s)" | \
           sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
           awk '{print 100 - $1}')
    line="    "
    printf "${line:${#c}}""%s %s" $c% | sed 's/ //g'
    
}
Memory() {
     mem=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
     memp=${mem:0:-2}%
     line="       "
     printf "${line:${#memp}}""%s %s" $memp | sed 's/ //g'
}
Wifi() {
    wifi=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
    if [[ "$wifi" == "" ]]; then
        echo -e "%{F#9B59B6} %{F#4A90E2}Not Connected"
    else
        echo -e "%{F#9B59B6} %{F#4A90E2}$wifi"
    fi
}
Sound() {
    NOTMUTED=$(amixer sget Master | grep "\[on\]")
    if [[ ! -z $NOTMUTED ]]; then
        VOL=$(amixer get Master | sed -n 's/.*\[\([0-9]*\)%\].*/\1/p' | head -n 1)
        if [ "$VOL" -ge 50 ]; then
            ICON=""
        elif [ "$VOL" -ge 20 ]; then
            ICON=""
        else
            ICON=""
        fi
        echo -e "%{F#9B59B6}${ICON} %{F#4A90E2}${VOL}%"
    else
        echo -e "%{F#9B59B6} %{F#4A90E2}Muted"
    fi
}
Bluetooth() {
    BT_STATUS=$(bluetoothctl show | grep "Powered: yes")
    if [[ -z $BT_STATUS ]]; then
        echo -n "Off"
    else
        CONNECTED=$(bluetoothctl devices Connected | grep "Device" | awk '{print $2}')
        if [[ -z $CONNECTED ]]; then
            echo -n "On (No Devices)"
        else
            DEVICE_NAMES=$(bluetoothctl devices Connected | awk '{for (i=3; i<=NF; i++) printf $i " "; print ""}')
            echo -n "On (${DEVICE_NAMES})"
        fi
    fi
}
Brightness() {
    echo $(expr $(brightnessctl g) / 8)
}
bright() {
    yad --scale \
        --value=$(brightnessctl g) \
        --min-value=10 \
        --width=500 \
        --max-value=800 \
        --print-partial \
        --hide-value \
        --no-buttons | while read -r value; do
            brightnessctl s "$value"
        done

}
sound() {
    yad --scale \
        --value=$(amixer sget Master | awk -F'[][]' '/Left:/ {print $2}' | tr -d '%') \
        --min-value=0 \
        --width=500 \
        --max-value=100 \
        --print-partial \
        --hide-value \
        --no-buttons | while read -r value; do
            amixer sset Master "$value%"
        done

}
mute() {
    amixer sset Master toggle
}
manage() {
    while read -r line; do 
        if [[ "$line" == "bluetooth" ]]; then
            blueman-manager &
        elif [[ "$line" == "sys" ]]; then
            alacritty -e btop &
        elif [[ "$line" == "vol" ]]; then
            sound &
        elif [[ "$line" == "bright" ]]; then
            bright &
        elif [[ "$line" == "clock" ]]; then
            alacritty -e tty-clock &
        elif [[ "$line" == "mute" ]]; then
            mute
        elif [[ "$line" == "wifi" ]]; then
            wifi.sh &
        fi
    done
}
get_battery_icon() {
    BATTERY_PERCENT=$(upower -i $(upower -e | grep battery) | grep percentage | awk '{print $2}' | sed 's/%//')
    if [ "$BATTERY_PERCENT" -ge 80 ]; then
        echo ""
    elif [ "$BATTERY_PERCENT" -ge 60 ]; then
        echo ""
    elif [ "$BATTERY_PERCENT" -ge 40 ]; then
        echo ""
    elif [ "$BATTERY_PERCENT" -ge 20 ]; then
        echo ""
    else
        echo ""
    fi
}

battery() {
    upower -i $(upower -e | grep battery) | grep percentage | awk '{ printf $2 }'
}

bar() {
    local BAR_WIDTH=188 # Total width of the bar
    while true; do
        local left_content="  %{F#9B59B6}$(format_desktops)%{F#5B6A9D} $(User)"
        local center_content="%{A:clock:}%{F#5B6A9D}$(Clock)%{A}%{F-}"
        local right_content="%{A:wifi:}%{F#4A90E2}[$(Wifi)]%{A}\
%{A1:vol:}%{A2:mute:}[$(Sound)]%{A}%{A}\
%{A:bluetooth:}[%{F#9B59B6} %{F#4A90E2}$(Bluetooth)]%{A}\
%{A:bright:}[%{F#9B59B6} %{F#4A90E2}$(Brightness)%]%{A}\
%{A:bluetooth:}[%{F#9B59B6}$(get_battery_icon) %{F#4A90E2}$(battery)]%{A} "
        local left_raw=$(echo -e "$left_content" | sed 's/%{[^}]*}//g' | wc -m)
        local center_raw=$(echo -e "$center_content" | sed 's/%{[^}]*}//g' | wc -m)
        local right_raw=$(echo -e "$right_content" | sed 's/%{[^}]*}//g' | wc -m)
        local padding_left=$(printf "%*s" $(expr \( $BAR_WIDTH - $center_raw \) / 2 - $left_raw + 1))
        local padding_right=$(printf "%*s" $(expr $BAR_WIDTH - $right_raw - \( $BAR_WIDTH - \( $BAR_WIDTH - $center_raw \) / 2 \) ))
        echo -e "$left_content$padding_left$center_content$padding_right$right_content"
        sleep 1s
    done | lemonbar -B "#000000" -F "#FFFFFF" -f "FiraCodeNerdFont-Regular" -p -g x30++ | manage
}
bar
