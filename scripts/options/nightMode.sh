#!/usr/bin/env bash
source $HOME/.config/hyprlab/scripts/data/conf.env

file="$SCRIPT_DIR/cache/currentTemp"

get_status() {
    if [[ -f "$file" ]]; then
        echo "true"
    else
        echo "false"
    fi
    exit 0
}

activate() {
    hyprctl hyprsunset temperature 5000
    touch "$file"
    hyprlab notify normal Hyprlab Options "NightMode ON" -i preferences-system
    hyprlab message ok "NightMode ON"
    exit 0
}

desactivate() {
    hyprctl hyprsunset temperature 6200
    rm -f "$file"
    hyprlab notify normal Hyprlab Options "NightMode OFF" -i preferences-system
    hyprlab message ok "NightMode OFF"
    exit 0
}

toggle_mode() {
    if [[ -f "$file" ]]; then
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
    toggle        -> Toggle NightMode
    on            -> Turn on NightMode
    off           -> Turn off NightMode
    -h, --help    -> Show this message
EOF
}

case $1 in 
    toggle) toggle_mode ;;
    status) get_status ;;
    on) activate;;
    off) desactivate;;
    "" | -h | --help) help && exit 0;;
    *)hyprlab message fail "Unknown options : $1" && help
    exit 1;;
esac