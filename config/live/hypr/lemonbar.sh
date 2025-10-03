#!/bin/bash

# COLOR1="#908caa"
# COLOR2="#e0def4"
# COLOR3="#9ccfd8"
# COLOR4="#31748f"
# COLOR5="#191724"

COLOR1="#cca677"
COLOR2="#f3ebe0"
COLOR3="#73cfcf"
COLOR4="#2b745b"
COLOR5="#232525"
if [[ "$(pgrep -f "$0")" == "$$" ]]; then
    true
else
    killall lemonbar
fi
sleep 0.1
get_desktops() {
    hyprctl workspaces | grep workspace | awk '{ print $3 }'
}
get_active_tag() {
    hyprctl activeworkspace | grep workspace | awk '{ print $3 }'
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
    local DATETIME=$(date "+%a %-d %b, %-l:%M %p")
    echo -e -n "${DATETIME}"
}
User() {
    echo -n $USER@$HOSTNAME
}
Cpu() {
    local c=$(top -bn1 | grep "Cpu(s)" | \
           sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
           awk '{print 100 - $1}')
    local line="    "
    printf "${line:${#c}}""%s %s" $c% | sed 's/ //g'
    
}
Memory() {
     local mem=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
     local memp=${mem:0:-2}%
     local line="       "
     printf "${line:${#memp}}""%s %s" $memp | sed 's/ //g'
}
WIFI_FILE="$(mktemp /tmp/wifi_file.XXXX)"
init_wifid() {
    while true; do
        echo "$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)" > $WIFI_FILE
        sleep 1
    done
}
init_wifid &
Wifi() {
    local wifi="$(cat $WIFI_FILE)"
    if [[ "$wifi" == "" ]]; then
        echo -e "%{F$COLOR1} %{F$COLOR3}Not Connected"
    else
        echo -e "%{F$COLOR1} %{F$COLOR3}$wifi"
    fi
}

Sound() {
    local NOTMUTED=$(amixer sget Master | grep "\[on\]")
    if [[ ! -z $NOTMUTED ]]; then
        local VOL=$(amixer get Master | sed -n 's/.*\[\([0-9]*\)%\].*/\1/p' | head -n 1)
        local ICON=""
        if [ "$VOL" -ge 50 ]; then
            ICON=""
        elif [ "$VOL" -ge 20 ]; then
            ICON=""
        else
            ICON=""
        fi
        echo -e "%{F$COLOR1}${ICON} %{F$COLOR3}${VOL}%"
    else
        echo -e "%{F$COLOR1} %{F$COLOR3}Muted"
    fi
}
Music() {
    pactl list sink-inputs | grep "media.name" | cut -d '=' -f 2 | tr -d '"' | head -n 1
}
Bluetooth() {
    local BT_STATUS=$(bluetoothctl show | grep "Powered: yes")
    if [[ -z $BT_STATUS ]]; then
        echo -n "Off"
    else
        local CONNECTED=$(bluetoothctl devices Connected | grep "Device" | awk '{print $2}')
        if [[ -z $CONNECTED ]]; then
            echo -n "On (No Devices)"
        else
            local DEVICE_NAMES=$(bluetoothctl devices Connected | awk '{for (i=3; i<=NF; i++) printf $i " "; print ""}' | tr -s ' ')
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
get_battery_icon() {
    local CHARGING="$(upower -i $(upower -e | grep bat) | grep state | awk  '{ print $2 }')"
    local SYM=""
    if [[ "$CHARGING" == "charging" ]]; then
        SYM=""
    fi
    local BATTERY_PERCENT="$(upower -i $(upower -e | grep battery) | grep percentage | awk '{print $2}' | sed 's/%//')"
    if [ "$BATTERY_PERCENT" -ge 80 ]; then
        echo "$SYM"
    elif [ "$BATTERY_PERCENT" -ge 60 ]; then
        echo "$SYM"
    elif [ "$BATTERY_PERCENT" -ge 40 ]; then
        echo "$SYM"
    elif [ "$BATTERY_PERCENT" -ge 20 ]; then
        echo "$SYM"
    else
        echo "$SYM"
    fi
}

battery() {
    upower -i $(upower -e | grep battery) | grep percentage | awk '{ printf $2 }'
}
displayUnameOrMedia() {
    local music_name
    music_name=$(Music)
    local max_length=55
    if [[ -z "$music_name" || ${#music_name} -gt $max_length ]]; then
        User
    else
        echo -n "$music_name"
    fi
}
get_display_width() {
    local text="$1"
    python -c "import sys; print(len(sys.argv[1]))" "$text"
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
bar() {
    local BAR_WIDTH=189
    while true; do
        local left_content="  %{F$COLOR2}$(format_desktops)%{F$COLOR1}$(displayUnameOrMedia)"
        local center_content="   %{A:clock:}%{F$COLOR2}$(Clock)%{A}%{F-}"
        local right_content="%{A:wifi:}%{F$COLOR3}[$(Wifi)]%{A}\
%{A1:vol:}%{A2:mute:}[$(Sound)]%{A}%{A}\
%{A:bluetooth:}[%{F$COLOR4} %{F$COLOR3}$(Bluetooth)]%{A}\
%{A:bright:}[%{F$COLOR4} %{F$COLOR3}$(Brightness)%]%{A}\
%{A:bluetooth:}[%{F$COLOR2}$(get_battery_icon) %{F$COLOR3}$(battery)]%{A} "
        local left_raw=$(get_display_width "$(echo -e "$left_content" | sed 's/%{[^}]*}//g')")
        local center_raw=$(get_display_width "$(echo -e "$center_content" | sed 's/%{[^}]*}//g')")
        local right_raw=$(get_display_width "$(echo -e "$right_content" | sed 's/%{[^}]*}//g')")



        local padding_left=$(printf "%*s" $(expr \( $BAR_WIDTH - $center_raw \) / 2 - $left_raw))
        local padding_right=$(printf "%*s" $(expr $BAR_WIDTH - $right_raw - \( $BAR_WIDTH - \( $BAR_WIDTH - $center_raw \) / 2 \) ))
        echo -e "$left_content$padding_left$center_content$padding_right$right_content"
        sleep 0.2s
    done | lemonbar -B "$COLOR5" -F "$COLOR2" -f "FiraCode Nerd Font" -f "Noto Serif CJK KR" -f "Noto Serif CJK TC" -f "Noto Serif CJK SC"  -f "Noto Serif CJK JP" -f "Noto Serif CJK HK"  -p -g 1920x30+0+0 | manage
}
bar
