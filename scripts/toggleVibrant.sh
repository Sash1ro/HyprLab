#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"

file="$SCRIPT_DIR/cache/currentVibrant"
ICON="$HYPRLAB/assets/hypr.svg"

get_status() {
    if [[ -f "$file" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

activate_vibrant() {
    nvibrant 512 512 512 512
    echo 1 > "$file"
    notify-send -a "Hyprland" "Paramètres" "Vibrant activé" -i "$ICON"
}

deactivate_vibrant() {
    rm -f "$file"
    nvibrant 0 0 0 0
    notify-send -a "Hyprland" "Paramètres" "Vibrant désactivé" -i "$ICON"
}

toggle_vibrant() {
    if [[ -f "$file" ]]; then
        deactivate_vibrant
    else
        activate_vibrant
    fi
}

case "$1" in
    on)
        activate_vibrant
        ;;
    off)
        deactivate_vibrant
        ;;
    toggle)
        toggle_vibrant
        ;;
    status)
        get_status
        ;;
    *)
        echo "Usage: $0 {on|off|toggle|status}"
        exit 1
        ;;
esac
