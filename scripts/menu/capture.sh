#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"

recording_flag="$SCRIPT_DIR/cache/wf-recorder-active"

# Menu options
op1="  Screenshot screen"
op2="  Screenshot region"
op3="󰻂  Record screen"
op4="  Record region"

menu="$op1\n$op2\n$op3\n$op4"
[ -f "$recording_flag" ] && menu="$menu\nStop record"

choice=$(printf "%b" "$menu" | rofi -dmenu -i -p "MENU : " -theme "$ROFI_THEME/list.rasi")


# Handle choice
case "$choice" in
    "$op1") hyprshot -m output ;;
    "$op2") hyprshot -m region ;;
    "$op3") hyprlab record screen ;;
    "$op4") hyprlab record region ;;
    "Stop record") hyprlab record stop;;
    *) exit 0 ;;
esac
