#!/usr/bin/env bash
source "$HOME/.config/hyprlab/scripts/data/conf.env"

menu="$SCRIPT_DIR/menu"

#KILL ROFI
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

#OPTIONS
clip=" Clipboard"
calc="󰃬 Calcul"
capture=" Capture"
opt=" Options"
prof=" Profiles" 
tam=" TaskManager"
keys="󰌌 Keybinds"
power="⏻ Power"
lofi="󰎇 Online Music"
emoji="󰱰 Emoji Picker"
custom=" Customizations"

prompt="$clip
$calc
$capture
$tam
$lofi
$emoji
$prof
$opt
$keys
$power
$custom"

show_help() {
cat <<EOF
Usage:
  hyprlab menu -> show the general menu
  hyprlab menu <command>

Commands :
    clip                    -> Show the clipboard
    calc                    -> Show a calcul menu
    capture                 -> Show a capture menu
    options                 -> Show options menu
    emoji                   -> Show emojis
    music                   -> Show online Music menu
    wifi                    -> Show the wifi menu
    profile                 -> Show the profile menu
    keybinds                -> Show keybinds
    themes                  -> Show themes 
    waybar                  -> Show waybar themes
    wallpapers,wall         -> Show wallpapers
    wallpapers-all, walls   -> Show all wallpapers
    customizations, custom  -> show the general themes menu
    -h, --help              -> Show this message
EOF
}

#handle CLI
v=""
case ${1:-} in
    clip) v=$clip;;
    calc) v=$calc;;
    capture) v=$capture;;
    options) v=$opt;;
    emoji)v=$emoji;;
    music)v=$lofi;;
    wifi) "$menu/wifi.sh";;
    profile)v=$prof;;
    keybinds)v=$keys;;
    themes)"$menu/theme-picker.sh";;
    waybar)"$menu/waybar-picker.sh";;
    wallpapers|wall)"$menu/wallpaper-switcher.sh";;
    wallpapers-all|walls)"$menu/wallpaper-switcher.sh" all;;
    customization|custom)v=$custom;;
    --help|-h) show_help;;
    "")v=$(echo -e "$prompt" | rofi -dmenu -l 20 -i -p "MENU : " -theme $ROFI_THEME/list.rasi);;
    *)hyprlab message fail "Invalid option : $1" && exit 1;; 
esac

#SETTING UP OPTIONS 
case $v in
    "$clip") "$menu/clip.sh";;

    "$calc") "$menu/calc.sh" show;;

    "$emoji")"$menu/emoji-picker.sh";;

    "$lofi") "$menu/lofi.sh";;

    "$keys") "$menu/keybinds.sh";;

    "$capture") "$menu/capture.sh";;

    "$tam") "$SCRIPT_DIR/apps/btop.sh";;

    "$opt") shift && "$menu/options.sh" ${@:-};;

    "$prof") "$menu/profilesmenu.sh";;

    "$custom") "$menu/customization.sh";;

    "$power") wlogout -b 4;;
    *) exit 0
esac


