#!/usr/bin/env bash

themeFolder="$HOME/.config/rofi/themes"
scriptFolder="$HOME/.config/hyprlab/scripts/"


#KILL ROFI
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

#OPTIONS
clip="  Clipboard"
capture="   Capture"
opt="   Options"
keys="󰌌   Keybinds"
custom="   Customizations"

prompt="$clip
$capture
$opt
$keys
$custom"

#POP ROFI
v=$(echo -e "$prompt" | rofi -dmenu -i -p "MENU : " -theme $themeFolder/list.rasi)


custom_menu() {
    local theme="   Themes"
    local waybar="   Waybar themes"
    local wallpaper="󰸉   Wallpapers"
    local p="$theme\n$waybar\n$wallpaper"

    local v=$(echo -e "$p" | rofi -dmenu -i -p "MENU : " -theme $themeFolder/list.rasi)

    case $v in 
        "$theme") "$scriptFolder/theme-picker.sh";;
        "$wallpaper") "$scriptFolder/wallpaper-switcher.sh" &;;
        "$waybar") "$scriptFolder/waybar-picker.sh";;
        *)exit 0
    esac
}


#SETTING UP OPTIONS 
case $v in
    "$clip") "$scriptFolder/clip.sh";;

    "$capture") "$scriptFolder/capture.sh";;

    "$custom") custom_menu;;
    *) exit 0
esac


