#!/usr/bin/env bash
source "$HOME/.config/hyprlab/scripts/data/conf.env"

#KILL ROFI
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi   
   
theme=" Themes"
waybar=" Waybar themes"
wallpaper="󰸉 Wallpapers"
wallpaperall="󰸉 All Wallpapers"
p="$theme\n$waybar\n$wallpaper\n$wallpaperall"

v=$(echo -e "$p" | rofi -dmenu -i -p "Customizations : " -theme $ROFI_THEME/list.rasi)

case $v in 
    "$theme") "$SCRIPT_DIR/menu/theme-picker.sh";;
    "$wallpaper") "$SCRIPT_DIR/menu/wallpaper-switcher.sh";;
    "$wallpaperall") "$SCRIPT_DIR/menu/wallpaper-switcher.sh" all;;
    "$waybar") "$SCRIPT_DIR/menu/waybar-picker.sh";;
    *)exit 0
esac