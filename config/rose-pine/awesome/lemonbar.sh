#!/bin/bash
if [[ "$(pgrep -f "$0")" == "$$" ]]; then
    true
else
    killall lemonbar
fi
sleep 0.1
get_desktops() {    
    awesome-client 'tags = screen[mouse.screen].tags; names = {}; for _, tag in ipairs(tags) do table.insert(names, tag.name) end; return table.concat(names, " ")' | sed 's/^ *string "//' | sed 's/"$//'
}
get_active_tag() {
    awesome-client 'return screen[mouse.screen].selected_tag and screen[mouse.screen].selected_tag.name or ""' | sed 's/^ *string "//' | sed 's/"$//'  
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
        echo -e "%{F#908caa} %{F#9ccfd8}Not Connected"
    else
        echo -e "%{F#908caa} %{F#9ccfd8}$wifi"
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
        echo -e "%{F#908caa}${ICON} %{F#9ccfd8}${VOL}%"
    else
        echo -e "%{F#908caa} %{F#9ccfd8}Muted"
    fi
}
Music() {
    pactl list sink-inputs | grep "media.name" | cut -d '=' -f 2 | tr -d '"' | head -n 1
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
get_battery_icon() {
    CHARGING="$(upower -i $(upower -e | grep bat) | grep state | awk  '{ print $2 }')"
    SYM=""
    if [[ "$CHARGING" == "charging" ]]; then
        SYM=""
    fi
    BATTERY_PERCENT="$(upower -i $(upower -e | grep battery) | grep percentage | awk '{print $2}' | sed 's/%//')"
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
#displayUnameOrMedia() {
#    if [[ "$(Music)" == "" ]]; then
#        User
#    else
#        Music
#    fi
#}
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
    echo -n "$text" | awk 'BEGIN { w = 0 }
    {
        for (i = 1; i <= length($0); i++) {
            c = substr($0, i, 1)
            if (c ~ /[^\x00-\x7F]/) w += 2  # Count wide characters as 2
            else w += 1                   # Count narrow characters as 1
        }
    }
    END { print w }'
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
    local BAR_WIDTH=194
    while true; do
        local left_content="  %{F#e0def4}$(format_desktops)%{F#908caa}$(displayUnameOrMedia)"
        local center_content="%{A:clock:}%{F#e0def4}$(Clock)%{A}%{F-}"
        local right_content="%{A:wifi:}%{F#9ccfd8}[$(Wifi)]%{A}\
%{A1:vol:}%{A2:mute:}[$(Sound)]%{A}%{A}\
%{A:bluetooth:}[%{F#31748f} %{F#9ccfd8}$(Bluetooth)]%{A}\
%{A:bright:}[%{F#31748f} %{F#9ccfd8}$(Brightness)%]%{A}\
%{A:bluetooth:}[%{F#e0def4}$(get_battery_icon) %{F#9ccfd8}$(battery)]%{A} "
        local left_raw=$(get_display_width "$(echo -e "$left_content" | sed 's/%{[^}]*}//g')")
        local center_raw=$(get_display_width "$(echo -e "$center_content" | sed 's/%{[^}]*}//g')")
        local right_raw=$(get_display_width "$(echo -e "$right_content" | sed 's/%{[^}]*}//g')")
        local padding_left=$(printf "%*s" $(expr \( $BAR_WIDTH - $center_raw \) / 2 - $left_raw + 5))
        local padding_right=$(printf "%*s" $(expr $BAR_WIDTH - $right_raw - \( $BAR_WIDTH - \( $BAR_WIDTH - $center_raw \) / 2 \) ))
        # local padding_left=$(printf "%*s" $(((BAR_WIDTH-center_raw)/2-left_raw+5))
        # local padding_right=$(printf "%*s" $((BAR_WIDTH-right_raw-(BAR_WIDTH-(BAR_WIDTH-center_raw)/2))))
        echo -e "$left_content$padding_left$center_content$padding_right$right_content"
        sleep 0.2s
    done | lemonbar -B "#191724" -F "#e0def4" -f "FiraCode Nerd Font" -f "Noto Serif CJK KR" -f "Noto Serif CJK TC" -f "Noto Serif CJK SC"  -f "Noto Serif CJK JP" -f "Noto Serif CJK HK"  -p -g x30++ | manage
}
bar
