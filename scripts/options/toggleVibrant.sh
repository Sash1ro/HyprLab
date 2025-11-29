#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"
file="$SCRIPT_DIR/cache/currentVibrant"

get_status() {
    if [[ -f "$file" ]]; then
        echo "true"
    else
        echo "false"
    fi
    exit 0
}

activate_vibrant() {
    nvibrant 512 512 512 512
    touch "$file"
    hyprlab notify normal Hyprlab Modes "Vibrant on" -i hypr
    hyprlab message ok "Vibrant on"
    exit 0
}

deactivate_vibrant() {
    rm -f "$file"
    nvibrant 0 0 0 0
    hyprlab notify normal Hyprlab Modes "Vibrant off" -i hypr
    hyprlab message ok "Vibrant off"
    exit 0
}

toggle_vibrant() {
    if [[ -f "$file" ]]; then
        deactivate_vibrant
    else
        activate_vibrant
    fi
}

help() {
cat <<EOF
Usage:
  $(basename $0) <command>

Commands :
    status        -> Get current state
    toggle        -> Toggle vibrant
    on            -> Turn on vibrant
    off           -> Turn off vibrant
    -h, --help    -> Show this message
EOF
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
    "" | -h | --help) help && exit 0;;
    *)
        hyprlab message fail "Unknown options : $1"
        help
        exit 1
        ;;
esac
