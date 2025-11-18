#!/usr/bin/env bash

themeFolder="$HOME/.config/rofi/themes"
scriptFolder="$HOME/.config/hyprlab/scripts/"
videoFolder="$HOME/Videos"

recording_flag="$scriptFolder/cache/wf-recorder-active"

if [ ! -d $videoFolder ]; then 
    mkdir $videoFolder
fi

# Menu options
op1="  Screenshot screen"
op2="  Screenshot region"
op3="󰻂  Record screen"
op4="  Record region"

menu="$op1\n$op2\n$op3\n$op4"
[ -f "$recording_flag" ] && menu="$menu\nStop record"

choice=$(printf "%b" "$menu" | rofi -dmenu -i -p "MENU : " -theme "$themeFolder/list.rasi")


record() {
    local mode="$1"
    local dateTime
    dateTime=$(date +%Y-%m-%d-%H-%M-%S)

    if [ -f "$recording_flag" ]; then
        notify-send -a "Hyprland" "Capture" "Recording already in progress!"
        exit 0
    fi

    touch "$recording_flag"

    if [ "$mode" = "screen" ]; then
        region=$(slurp -o)
        [ -z "$region" ] && { rm -f "$recording_flag"; exit 0; }

        notify-send -a "Hyprland" "Capture" "Starting monitor recording..."
        wf-recorder --audio --bframes max_b_frames -g "$region" -f "$videoFolder/$dateTime.mp4"
    else
        region=$(slurp)
        [ -z "$region" ] && { rm -f "$recording_flag"; exit 0; } 
        notify-send -a "Hyprland" "Capture" "Starting region recording..."
        wf-recorder --audio --bframes max_b_frames -g "$region" -f "$videoFolder/$dateTime.mp4"
    fi

    rm -f "$recording_flag"
}


# Handle choice
case "$choice" in
    "$op1") hyprshot -m output ;;
    "$op2") hyprshot -m region ;;
    "$op3") record screen ;;
    "$op4") record region ;;
    "Stop record")
        if pgrep -x "wf-recorder" > /dev/null; then
            pkill -INT -x wf-recorder
            notify-send -a "Hyprland" "Capture" "Recording stopped, file live in :\n$videoFolder"
        fi
        ;;
    *) exit 0 ;;
esac
