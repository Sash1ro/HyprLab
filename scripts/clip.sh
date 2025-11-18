#!/bin/bash

themeFolder="$HOME/.config/rofi/themes"

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi


case $1 in
    d) cliphist list | rofi -dmenu -i -theme $themeFolder/clip.rasi | cliphist delete
       ;;

    w) if [ `echo -e "Clear\nCancel" | rofi -dmenu -p "Effacer l'historique ?" -theme $themeFolder/confirm.rasi` == "Clear" ] ; then
            cliphist wipe
       fi
       ;;

    *) cliphist list | rofi -dmenu -display-columns 2 -theme $themeFolder/clip.rasi  | cliphist decode | wl-copy
       ;;
esac
