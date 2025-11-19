#!/usr/bin/env bash
source $HOME/.config/hyprlab/scripts/data/conf.env

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
v=$(echo -e "$prompt" | rofi -dmenu -i -p "MENU : " -theme $ROFI_THEME/list.rasi)


custom_menu() {
    local theme="   Themes"
    local waybar="   Waybar themes"
    local wallpaper="󰸉   Wallpapers"
    local p="$theme\n$waybar\n$wallpaper"

    local v=$(echo -e "$p" | rofi -dmenu -i -p "MENU : " -theme $ROFI_THEME/list.rasi)

    case $v in 
        "$theme") "$SCRIPT_DIR/theme-picker.sh" &;;
        "$wallpaper") "$SCRIPT_DIR/wallpaper-switcher.sh" &;;
        "$waybar") "$SCRIPT_DIR/waybar-picker.sh" &;;
        *)exit 0
    esac
}


#SETTING UP OPTIONS 
case $v in
    "$clip") "$SCRIPT_DIR/clip.sh" &;;

    "$capture") "$SCRIPT_DIR/capture.sh" &;;

    "$custom") custom_menu;;
    *) exit 0
esac


