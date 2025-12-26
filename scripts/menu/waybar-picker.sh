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
    currentTheme="None"
fi

if [ ! -d "$themeFolder" ]; then
    echo "$themeFolder is not a directory"
    exit 1
fi


themes=()
currentLine="󱝁 $currentTheme"
themes+=("$currentLine")
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

selected=$(printf '%s\n' "${themes[@]}" | rofi -dmenu -p "Waybar : " -a 0 -selected-row 1 -theme $rofiConf  )


if [ -z "$selected" ] || [[ "$selected" == ">>"* ]]; then
    exit 0
fi

hyprlab waybar -t $selected 


