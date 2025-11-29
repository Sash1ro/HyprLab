#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi


case $1 in
    d) cliphist list | rofi -dmenu -i -theme $ROFI_THEME/clip.rasi | cliphist delete
       ;;

    w) if [ `echo -e "Clear\nCancel" | rofi -dmenu -p "Effacer l'historique ?" -theme $ROFI_THEME/confirm.rasi` == "Clear" ] ; then
            cliphist wipe
       fi
       ;;

    *) cliphist list | rofi -dmenu -display-columns 2 -theme $ROFI_THEME/clip.rasi  | cliphist decode | wl-copy
       ;;
esac
