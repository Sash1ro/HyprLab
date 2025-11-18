#!/bin/bash

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

echo "" | rofi -dmenu -p "Search:" -theme $HOME/.config/rofi/themes/search.rasi | xargs -I{} xdg-open "https://www.google.com/search?q={}"
