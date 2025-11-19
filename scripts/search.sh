#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

echo "" | rofi -dmenu -p "Search:" -theme $ROFI_THEME/search.rasi | xargs -I{} xdg-open "https://www.google.com/search?q={}"
