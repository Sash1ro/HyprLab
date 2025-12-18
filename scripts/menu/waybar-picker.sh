#!/usr/bin/env bash
source "$HOME/.config/hyprlab/scripts/data/conf.env"

configFolder="$HOME/.config"
themeFolder="$configFolder/hyprlab/waybar/themes"
rofiConf="$ROFI_THEME/list.rasi"
currentLink="$themeFolder/current"

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

if [ -L "$currentLink" ]; then
    currentTheme=$(basename "$(readlink -f "$currentLink")")
else
    currentTheme="Aucun"
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

selected=$(printf '%s\n' "${themes[@]}" | rofi -dmenu -p "Waybar : " -theme $rofiConf  )


if [ -z "$selected" ] || [[ "$selected" == ">>"* ]]; then
    exit 0
fi

hyprlab waybar -t $selected 


