#!/bin/bash

SCRIPT_DIR="$HOME/.config/hyprlab/scripts/"
file="$SCRIPT_DIR/cache/currentVibrant.txt"
ICON="$HOME/.config/hyprlab/assets/hypr.svg"

if [ -f "$file" ]; then
    current=$(cat "$file")
else
    current=0
fi

activate_vibrant() {
    nvibrant 512 512 512 512
    echo 1 > "$file"
    notify-send -a "Hyprland" "Paramètres" "Vibrant activé" -i $ICON
}

deactivate_vibrant() {
    nvibrant 0 0 0 0
    echo 0 > "$file"
    notify-send -a "Hyprland" "Paramètres" "Vibrant désactivé" -i $ICON
}

case "$1" in
    on)
        activate_vibrant
        ;;
    off)
        deactivate_vibrant
        ;;
    status)
        if [ "$current" -eq 1 ]; then
            echo "true"
        else
            echo "false"
        fi
        ;;
    *)
        echo "Usage : $0 {on|off|status}"
        exit 1
        ;;
esac
