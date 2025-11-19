#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

themeSwitcher="$SCRIPT_DIR/themes-switcher.sh"
currentLink="$THEMES_DIR/current"

notifIcon="$HYPRLAB/assets/hypr.svg"

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

if [ ! -d "$THEMES_DIR" ]; then
    echo "Le dossier $THEMES_DIR n'existe pas."
    exit 1
fi


themes=()
for folder in "$THEMES_DIR"/*; do
    name=$(basename "$folder")
    if [ "$name" != "current" ] && [ "$name" != "$currentTheme" ] && [ "$name" != "size" ]; then
        themes+=("$name")
    fi
done


if [ ${#themes[@]} -eq 0 ]; then
    echo "Aucun thème trouvé dans $THEMES_DIR."
    exit 1
fi

currentLine=">>$currentTheme"
themes+=("$currentLine")
themes=($(printf '%s\n' "${themes[@]}" | sort))

selected=$(printf '%s\n' "${themes[@]}" | rofi -dmenu -p "Choisir un thème:" -theme $ROFI_THEME/list.rasi  )


if [ -z "$selected" ] || [[ "$selected" == ">>"* ]]; then
    exit 0
fi

$themeSwitcher -t $selected >/dev/null
notify-send -a "Hyprland" "Thème modifié" "Actuel : $selected" -i $notifIcon
echo "Thème appliqué : $selected"



