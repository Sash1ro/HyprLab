#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"


"$HYPRLAB/update-swaync.sh"
nvim --headless -c "TransparentEnable" -c "qa!" && echo "error"

if [ ! -L "$HYPRLAB/hyprland/profiles/current" ]; then
    ln -sfn "$HYPRLAB/hyprland/conf" "$HYPRLAB/hyprland/profiles/current"
fi

swww img "$THEMES_DIR/current/wallpaper" --transition-type grow --transition-fps 60
hyprlab notify normal Hyprlab $USER "Welcome Back !" -i hand
