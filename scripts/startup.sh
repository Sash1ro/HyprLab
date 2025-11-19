#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

scripts="$HOME/.config/hyprlab/scripts"
ts="$scripts/themes-switcher.sh"

nvim --headless -c "TransparentEnable" -c "qa!" && echo "error"

swww-daemon & waybar & swaync

hyprctl monitors | grep -E "DP-[2-9]+" && $ts -s 2 || $ts -s 1 

selected="$("$scripts/themes-switcher.sh" --selected)"
$ts -t "$selected"
