#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

configFolder="$HOME/.config"
themeFolder="$configFolder/hyprlab/waybar/themes"
themeSwitcher="$configFolder/hyprlab/scripts/waybar-switcher.sh"
rofiConf="$ROFI_THEME/list.rasi"
currentLink="$themeFolder/current"

notifIcon="$configFolder/hyprlab/assets/hypr.svg"

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

if [ -L "$currentLink" ]; then
    currentTheme=$(basename "$(readlink -f "$currentLink")")
else
    currentTheme="Aucun"
fi

if [ ! -f "$themeSwitcher" ]; then
    echo "Script introuvable !"
    exit 1
fi

if [ ! -d "$themeFolder" ]; then
    echo "Le dossier $themeFolder n'existe pas."
    exit 1
fi


themes=()
for folder in "$themeFolder"/*; do
    name=$(basename "$folder")
    if [ "$name" != "current" ] && [ "$name" != "$currentTheme" ] && [ "$name" != "size" ]; then
        themes+=("$name")
    fi
done


if [ ${#themes[@]} -eq 0 ]; then
    echo "Aucun thème trouvé dans $themeFolder."
    exit 1
fi

currentLine=">>$currentTheme"
themes+=("$currentLine")
themes=($(printf '%s\n' "${themes[@]}" | sort))

selected=$(printf '%s\n' "${themes[@]}" | rofi -dmenu -p "Choisir un thème:" -theme $rofiConf  )


if [ -z "$selected" ] || [[ "$selected" == ">>"* ]]; then
    exit 0
fi

$themeSwitcher -t $selected >/dev/null
notify-send -a "Hyprland" "Waybar modifié" "Actuel : $selected" -i $notifIcon
echo "Waybar appliqué : $selected"



