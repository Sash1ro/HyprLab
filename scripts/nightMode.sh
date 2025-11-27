#!/usr/bin/env bash
source $HOME/.config/hyprlab/scripts/data/conf.env

file="$SCRIPT_DIR/cache/currentTemp"
ICON="$HYPRLAB/assets/hypr.svg"

get_status() {
    if [[ -f "$file" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

toggle_mode() {
    if [[ -f "$file" ]]; then
        hyprctl hyprsunset temperature 6200
        rm -f "$file"
    else
        hyprctl hyprsunset temperature 5000
        touch "$file"
    fi
}

case $1 in 
    "toggle") toggle_mode ;;
    "status") get_status ;;
    *)exit 0;;
esac