#!/usr/bin/env bash
turn_on_wifi() {
    nmcli radio wifi on
    echo "🔌 Wi-Fi turned on"
}
turn_off_wifi() {
    nmcli radio wifi off
    echo "🔌 Wi-Fi turned off"
}
toggle_wifi() {
    wifi_status=$(nmcli radio wifi)
    if [ "$wifi_status" == "enabled" ]; then
        turn_off_wifi
    else
        turn_on_wifi
    fi
}
wifi_device_name=$(nmcli -t -f DEVICE,TYPE d | grep "wifi *$" | sed 's/\\:/ESCAPEDCOLON/g' | sed 's/:.*//' | sed 's/ESCAPEDCOLON/\:/g')
current_wifi() {
    echo $(nmcli -t -f NAME,DEVICE c | grep "$wifi_device_name" | sed 's/\\:/ESCAPEDCOLON/g' | sed 's/:.*//' | sed 's/ESCAPEDCOLON/\:/g')
}
choose_wifi() {
    tmpfile=/tmp/wifi.list
    while read -r op; do
        echo $op >> $tmpfile
    done < <(nmcli -t -f SSID d wifi list --rescan yes | sort | uniq)
    chosen=$(yad --text "🔌 CONNECTED TO: $(current_wifi)" \
        --list \
        --separator="" \
        --column="📶 AVAILABLE WIFI" \
        --width=300 \
        --height=300 < $tmpfile)
    rm $tmpfile
    echo $chosen
}
choose_known_wifi() {
    tmpfile=/tmp/wifi.list
    while read -r op; do
        echo $op >> $tmpfile
    done < <(nmcli -f NAME c show | sed '1d' | sort | uniq)
    chosen=$(yad --text "🔌 CONNECTED TO: $(current_wifi)" \
        --list \
        --separator="" \
        --column="📶 PAIRED WIFI" \
        --width=300 \
        --height=300 < $tmpfile)
    rm $tmpfile
    echo $chosen
}
choose_what_to_do() {
    tmpfile=/tmp/choosewhat.todo
    > $tmpfile
    if nmcli -f NAME c show | grep -q "$1"; then
        echo "❌ Forget network" >> $tmpfile
        echo "🔗 Connect to network" >> $tmpfile
    else
        echo "🤝 Pair with network" >> $tmpfile
        echo "🔗 Connect to network" >> $tmpfile
    fi
    chosen=$(yad --list \
    --separator="" \
    --column="🛠️ PICK WHAT TO DO" \
    --width=300 \
    --height=300 < $tmpfile )
    rm $tmpfile
    echo $chosen
}
connect_to_wifi() {
    nmcli c up "$1"
    echo "🔗 Connecting to $1..."
}
get_security() {
    get=$(nmcli -t -f SSID,SECURITY d wifi list | sort | uniq | grep "$1:")
    if [[ "$get" =~ "WPA2 802.1X" ]]; then
        echo "enterprise"
    elif [[ "$get" =~ "WPA2" ]]; then
        echo "personal"
    elif [[ "$get" =~ "--" ]]; then
        echo "open"
    else
        echo "unidentified"
    fi 
}
forget_wifi() {
    nmcli c delete "$1"
    echo "❌ Network $1 forgotten."
}
connect_to_enterprise() {
    nmcli c add type wifi ifname '*' con-name "$1" ssid "$1"
    nmcli connection modify "$1" 802-11-wireless-security.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity $2 802-1x.password $3 802-1x.phase2-auth mschapv2
    return $?
}
connect_to_personal() {
    nmcli d wifi connect "$1" password "$2"
    return $?
}
connect_to_open() {
    nmcli d wifi connect "$1"
    return $?
}
establish_wifi() {
    if nmcli -f NAME c show | grep -q "$1"; then
        connect_to_wifi "$1"
        return
    fi
    security=$(get_security $1)
    if [[ "$security" == "enterprise" ]]; then
        result=$(yad --form \
            --separator="\n" \
            --field="👤 Username:" "" \
            --field="🔑 Password:":H "" \
            --width=300 \
            --height=300 \
        )
        uname=$(echo -e "$result" | sed -n '1p')
        password=$(echo -e "$result" | sed -n '2p')
        connect_to_enterprise $1 $uname $password
        if [[ $? -ne 0 ]]; then
            yad --text="🔴 Connection failed" --width=300 --height=300
            return
        fi
    elif [[ "$security" == "personal" ]]; then
        password=$(yad --form \
            --separator="" \
            --field="🔑 Password:":H "" \
            --width=300 \
            --height=300 \
        )
        connect_to_personal $1 $password
        if [[ $? -ne 0 ]]; then
            yad --text="🔴 Connection failed" --width=300 --height=300
            return
        fi
    elif [[ "$security" == "open" ]]; then
        connect_to_open $1
        if [[ $? -ne 0 ]]; then
            yad --text="🔴 Connection failed" --width=300 --height=300
            return
        fi
    else
        yad --text="⚠️ This network type is not recognized by this program" --width=300 --height=300
        return
    fi
    connect_to_wifi "$1"
}
main_menu() {
    cont="y"
    while [[ $cont == "y" ]]; do
        wifi_status=$(nmcli radio wifi)
        if [ "$wifi_status" == "enabled" ]; then
            WIFI_OPTION="off"
        else
            WIFI_OPTION="on"
        fi
        tmpfile=/tmp/menufile.wifisettings
        > $tmpfile
        echo "🔄 Toggle Wi-Fi $WIFI_OPTION" >> $tmpfile
        echo "📶 Select Wi-Fi" >> $tmpfile
        echo "📚 View known networks" >> $tmpfile
        chosen=$(yad --text "📱 MAIN MENU" \
            --text "🔌 CONNECTED TO: $(current_wifi)" \
            --list \
            --separator="" \
            --column="🖱️ Choose one" \
            --width=300 \
            --height=300 < $tmpfile --single)
        rm $tmpfile
        if [[ "$chosen" == "📶 Select Wi-Fi" ]]; then
            turn_on_wifi
            wifi=$(choose_wifi)
            todo=$(choose_what_to_do "$wifi")
            if [[ "$todo" == "❌ Forget network" ]]; then
                forget_wifi "$wifi"
            elif [[ "$todo" == "🔗 Connect to network" ]]; then
                connect_to_wifi "$wifi"
            elif [[ "$todo" == "🤝 Pair with network" ]]; then
                establish_wifi "$wifi"
            fi
        elif [[ "$chosen" == "📚 View known networks" ]]; then
            wifi=$(choose_known_wifi)
            todo=$(choose_what_to_do "$wifi")
            if [[ "$todo" == "❌ Forget network" ]]; then
                forget_wifi "$wifi"
            elif [[ "$todo" == "🔗 Connect to network" ]]; then
                connect_to_wifi "$wifi"
            fi
        elif [[ "$chosen" == "🔄 Toggle Wi-Fi $WIFI_OPTION" ]]; then
            toggle_wifi
        else
            cont=""
        fi
    done
}
main_menu
