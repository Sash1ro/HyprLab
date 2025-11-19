#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

players=$(playerctl -l 2>/dev/null | grep -vE "\bfirefox\b")

player=$(echo "$players" | head -n 1)

if [ -z "$player" ]; then
    echo "󰱶 Aucune Musique"
    exit 0
fi

status=$(playerctl -p $player status 2>/dev/null)

truncate_text() {
    local text="$1"
    local max="$2"
    local len=${#text}
    if [ "$len" -gt "$max" ]; then
        echo "${text:0:$max}…"
    else
        echo "$text"
    fi
}

song=$(playerctl -p $player metadata --format '{{title}}')
artist=$(playerctl -p $player metadata --format '{{artist}}')
Fsong=$(truncate_text "$song" 25)
Fartist=$(truncate_text "$artist" 25)

FORMAT=" ${Fsong} - ${Fartist}"

case "$status" in
    "Playing") echo -e "󰎆 $FORMAT";;
    "Paused")  echo -e " ${FORMAT}";;
    "Stopped"|"") echo -e "󰱶 Aucune Musique";;
esac
