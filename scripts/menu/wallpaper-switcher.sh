#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

current="$THEMES_DIR/current"
currentWallpaper="$current/wallpaper"

case $1 in
    all) WALLPAPER_ROOT="$HYPRLAB/wallpapers";;
    *)WALLPAPER_ROOT="$current/wallpapers";;
esac

mapfile -t originPath < <(find ${WALLPAPER_ROOT} -maxdepth 1 -type f)
declare -A bgresult

bgnames=()

#KILL ROFI
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

function getFileName {
    echo "$1" | xargs basename | awk -F'.' '{print $1}'
}

for pathIDX in "${!originPath[@]}"; do
    filename=$(getFileName "${originPath[$pathIDX]}")
    bgresult["${filename}"]="${originPath[$pathIDX]}"
    bgnames[$pathIDX]+="${filename}"
done


strrr=""
for fName in "${bgnames[@]}"; do
    strrr+="$(echo -n "${fName}\0icon\x1f${bgresult[$fName]}\n")"
done


selected=$(echo -en "${strrr}" | sort | PREVIEW=true rofi -dmenu -disable-history -i -theme $ROFI_THEME/wallpapersPicker.rasi)

if [ -z "$selected" ]; then
    exit 0
fi

themeName=$(basename "$current")

hyprlab wallpaper set "${bgresult[$selected]}" || hyprlab message fail "Error while applying wallpaper"
