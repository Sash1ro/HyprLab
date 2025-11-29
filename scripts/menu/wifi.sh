#!/usr/bin/env bash

config="$HOME/.config/hyprlab/rofi/themes/list.rasi"

# --------------------------
# Functions
# --------------------------

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

get_match() {
    selection=$(echo -e "$1" | rofi -dmenu -i -p "$2" -theme "$config")
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

question_box() {
    zenity --question --title="$1" --text="$2" --width=400
    return $?
}

notify() {
    notify-send "$1" "$2" -i network-wireless -t 3500
}

# --------------------------
# Variables
# --------------------------

toggle_entry="Turn WiFi"

state=$(nmcli -t -fields WIFI g)
enable_test=$(echo "$state" | grep "enabled")

if [[ -z "$enable_test" ]]; then
    question_box "Enable WiFi" "WiFi is currently OFF. Enable it?"
    if [[ $? -eq 0 ]]; then
        nmcli radio wifi on
        notify "WiFi Enabled" "WiFi has been turned ON"
    fi
    exit 0
else
    toggle="󰤭 $toggle_entry off"
    notify-send "WiFi" "Fetching avaible connections..." -i network-wireless -t 2000
fi

fields="SSID,BARS,SECURITY"
lines_full=$(nmcli --terse --fields $fields dev wifi)

# Remove empty SSIDs + duplicates
lines_full=$(echo -e "$lines_full" | awk -F ":" 'length($1) > 0 {print $0}' | awk -F ":" '!seen[$1]++')

current_ssid=$(LC_ALL=C nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2)
lines=""

# Build lines with icon only once
while IFS= read -r line; do
    ssid=$(echo "$line" | awk -F ":" '{print $1}')
    bars=$(echo "$line" | awk -F ":" '{print $2}')
    security=$(echo "$line" | awk -F ":" '{print $3}')
    icon=" "  # default icon

    saved_con=$(nmcli con show | awk -v ssid="$ssid" '$0 ~ ssid {print $1}')
    if [[ -n "$saved_con" ]]; then
        icon=" "   # icon for saved network
    fi

    if [[ "$security" == "--" || -z "$security" ]]; then
        icon=" "  # different icon for open networks
    fi
    if [[ "$ssid" == "$current_ssid" ]]; then 
        icon=" "  # current network icon
    fi

    lines+="$icon$ssid  $bars"$'\n'
done <<< "$lines_full"
lines="${lines%$'\n'}"

# Build menu
menu_items="$toggle\n$lines"

# --------------------------
# Menu selection
# --------------------------

selection=$(get_match "$menu_items" "WiFi Menu") || exit 0

# Determine SSID from selection
if [[ "$selection" == "$toggle" ]]; then
    selected_ssid="$selection"
else
    # Remove icon prefix (assume 1 char width icon + space) and trailing bars
    selected_ssid=$(echo "$selection" | sed 's/^.\{2\}//;s/  .*//')
fi

# --------------------------
# Handle selection
# --------------------------


# Toggle WiFi
if [[ "$selected_ssid" = "$toggle" ]]; then
    nmcli radio wifi off && notify "WiFi Disabled" "WiFi turned OFF"
    exit 0
fi

# Existing saved connection
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

# New connection (802.1X)
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

# WPA/WEP
sec=$(echo -e "$lines_full" | grep "$selected_ssid" | awk '/(WPA|WEP)/')
if [[ -n "$sec" ]]; then
    password=$(entry_box "Password" "Enter password:") || exit 0
fi
nmcli dev wifi con "$selected_ssid" password "$password" && notify "Connected" "Connected to $selected_ssid"
exit 0
