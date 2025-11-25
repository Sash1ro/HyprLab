#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

scripts="$HOME/.config/hyprlab/scripts"

nvim --headless -c "TransparentEnable" -c "qa!" && echo "error"

swww-daemon & waybar & swaync 

swww img "$THEMES_DIR/current/wallpaper" --transition-type grow --transition-fps 60
