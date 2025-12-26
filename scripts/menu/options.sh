#!/usr/bin/env bash
source "$HOME/.config/hyprlab/scripts/data/conf.env"

#KILL ROFI
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi  

index=${1:-0}

hypr=" Hyprland"
wifi=" WIFI"
conn="󰈀 Internet"
bt="󰂯 Bluetooth"
sound=" Sound"

vibrant=" Vibrant"
if [[ "$($SCRIPT_DIR/options/toggleVibrant.sh status)" == "true" ]]; then
    vibrant=" Vibrant"
fi

gamemode=" Gamemode"
if [[ "$($SCRIPT_DIR/options/gamemode.sh status)" == "true" ]]; then
    gamemode=" Gamemode"
fi
clip="󱘜 Clear Clipboard"

p="$vibrant\n$gamemode\n$hypr\n$wifi\n$conn\n$bt\n$sound\n$clip"

v=$(echo -e "$p" | rofi -dmenu -i -p "Options : " -l 10 -selected-row $index -theme $ROFI_THEME/list.rasi)

case $v in
    "$hypr")"$SCRIPT_DIR/menu/hypropt.sh";;
    "$wifi") "$SCRIPT_DIR/menu/wifi.sh" &;;
    "$conn")pkill nm-connection-editor && hyprctl dispatch exec nm-connection-editor || hyprctl dispatch exec nm-connection-editor;;
    "$bt")pkill blueman-manager && hyprctl dispatch exec blueman-manager || hyprctl dispatch exec blueman-manager;;
    "$sound")pkill pavucontrol && hyprctl dispatch exec pavucontrol || hyprctl dispatch exec pavucontrol;;
    "$vibrant") "$SCRIPT_DIR/options/toggleVibrant.sh" toggle && "$SCRIPT_DIR/menu/options.sh" 0;;
    "$gamemode") "$SCRIPT_DIR/options/gamemode.sh" toggle && "$SCRIPT_DIR/menu/options.sh" 1;;
    "$clip") "$SCRIPT_DIR/menu/clip.sh" w;;
    *)exit 0
esac    