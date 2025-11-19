#!/usr/bin/env bash
source $HOME/.config/hyprlab/scripts/data/conf.env

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
ICON="$HOME/.config/hyprlab/assets/hypr.svg"

if [ "$HYPRGAMEMODE" = 1 ] ; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword animation borderangle,0; \
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
	    keyword decoration:fullscreen_opacity 1;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
    notify-send -a "Hyprland" "Modes" "GameMode activé !" -i $ICON
    exit
else
    notify-send -a "Hyprland" "Modes" "GameMode Désactivé !" -i $ICON
    hyprctl reload
    exit 0
fi
exit 1