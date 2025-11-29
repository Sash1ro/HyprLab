#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

# Get current Bluetooth state (0 = unblocked, 1 = blocked)
state=$(rfkill list bluetooth | grep "Soft blocked" | awk '{print $3}')

getStatus() {
    if [[ "$state" == "no" ]]; then
        echo "true"
    else
        echo "false"
    fi
    exit 0
}

activate() {
    rfkill unblock bluetooth # turn on
    hyprlab notify normal Hyprlab Modes "Bluetooth ON" -i hypr
    hyprlab message ok "Bluetooth ON" 
    exit 0
}

desactivate() {
    rfkill block bluetooth   # turn off
    hyprlab notify normal Hyprlab Modes "Bluetooth OFF" -i hypr
    hyprlab message ok "Bluetooth OFF"
    exit 0
}

toggle() {
    if [ "$state" = "no" ]; then
        desactivate
    else
        activate
    fi
}

help() {
cat <<EOF
Usage:
  $(basename $0) <command>

Commands :
    status        -> Get current state
    toggle        -> Toggle bluetooth
    on            -> Turn on bluetooth
    off           -> Turn off bluetooth
    -h, --help    -> Show this message
EOF
}

case $1 in
    status) getStatus;;
    toggle) toggle;;
    on) activate;;
    off) desactivate;;
    "" | -h | --help) help && exit 0;;
    *)hyprlab message fail "Unknown command : $1" && help && exit 1;;
esac