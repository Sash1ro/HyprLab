#!/usr/bin/env bash

config="$HOME/.config/hyprlab/rofi/themes/list.rasi"
source "$HOME/.config/hyprlab/scripts/data/conf.env"

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

get_match() {
    index=${3:-1}
    selection=$(echo -e "$1" | rofi -dmenu -i -a 0 -selected-row $index -p "$2" -theme "$config")
    [[ $? -ne 0 ]] && return 1
    [[ -z "$selection" ]] && return 1
    does_match_=$(echo -e "$1" | grep -Fx "$selection")
    [[ -z "$does_match_" ]] && return 1
    echo "$selection"
    return 0
}

entry_box() {
    value=$(zenity --entry --title="$1" --text="$2" --width=250)
    [[ $? -ne 0 ]] && return 1
    echo "$value"
    return 0
}

notify() {
    notify-send "$1" "$2" -i network-wireless -t 3500
}

toggle_entry="Turn WiFi"

state=$(nmcli -t -fields WIFI g)
enable_test=$(echo "$state" | grep "enabled")

if [[ -z "$enable_test" ]]; then
    nmcli radio wifi on && notify "WiFi turned ON" "Fetching avaible connections..."
    sleep 2
else
    notify "WiFi" "Fetching avaible connections..."
fi

toggle="󰤭 $toggle_entry off"


fields="SSID,BARS,SECURITY"
lines_full=$(nmcli --terse --fields $fields dev wifi)

lines_full=$(echo -e "$lines_full" | awk -F ":" 'length($1) > 0 {print $0}' | awk -F ":" '!seen[$1]++')

current_ssid=$(LC_ALL=C nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2)
lines=""

active=0
i=0
while IFS= read -r line; do
    ssid=$(echo "$line" | awk -F ":" '{print $1}')
    bars=$(echo "$line" | awk -F ":" '{print $2}')
    security=$(echo "$line" | awk -F ":" '{print $3}')
    ((i++))
    icon=" "  

    saved_con=$(nmcli con show | awk -v ssid="$ssid" '$0 ~ ssid {print $1}')
    if [[ -n "$saved_con" ]]; then
        icon=" "   
    fi

    if [[ "$security" == "--" || -z "$security" ]]; then
        icon=" "  
    fi
    if [[ "$ssid" == "$current_ssid" ]]; then 
        active=$i
        icon=" "  
    fi

    lines+="$icon$ssid  $bars"$'\n'
done <<< "$lines_full"
lines="${lines%$'\n'}"

menu_items="$toggle\n$lines"

selection=$(get_match "$menu_items" "WiFi :" $active) || exit 0

if [[ "$selection" == "$toggle" ]]; then
    selected_ssid="$selection"
else
    selected_ssid=$(echo "$selection" | sed 's/^.\{2\}//;s/  .*//')
fi

if [[ "$selected_ssid" = "$toggle" ]]; then
    nmcli radio wifi off && notify "WiFi Disabled" "WiFi turned OFF"
    exit 0
fi

matches=$(nmcli con show | awk -v ssid="$selected_ssid" '$0 ~ ssid {print $1}')
if [[ -n "$matches" ]]; then
    n_matches=$(echo -e "$matches" | wc -l)
    if [[ $n_matches -eq 1 ]]; then
        nmcli con up "$selected_ssid" && notify "Connected" "Connected to $selected_ssid"
    else
        chosen_con=$(get_match "$matches" "Choose connection") || exit 0
        nmcli con up "$chosen_con" && notify "Connected" "Connected to $chosen_con"
    fi
    exit 0
fi

wlan=$(nmcli dev | grep wifi | awk '{print $1}')
sec0=$(echo -e "$lines_full" | grep "$selected_ssid" | awk '/802\.1X/')

if [[ -n "$sec0" ]]; then
    user=$(entry_box "Identity" "Enter identity:") || exit 0
    [[ -z "$user" ]] && exit 0
    password=$(entry_box "Password" "Enter password (leave empty):") || exit 0
    if [[ $(echo -e "$wlan" | wc -l) -gt 1 ]]; then
        wlan=$(get_match "$wlan" "Select Interface") || exit 0
    fi
    nmcli con add type wifi con-name "$selected_ssid" ifname "$wlan" ssid "$selected_ssid" -- \
        wifi-sec.key-mgmt wpa-eap 802-1x.eap ttls \
        802-1x.phase2-auth mschapv2 802-1x.identity "$user" 802-1x.password "$password"
    nmcli con up "$selected_ssid" && notify "Connected" "Connected to $selected_ssid"
    exit 0
fi

sec=$(echo -e "$lines_full" | grep "$selected_ssid" | awk '/(WPA|WEP)/')
if [[ -n "$sec" ]]; then
    password=$(entry_box "Password" "Enter password:") || exit 0
fi
nmcli dev wifi con "$selected_ssid" password "$password" && notify "Connected" "Connected to $selected_ssid"
exit 0
