#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"

currentLink="$THEMES_DIR/current"

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

if [ -L "$currentLink" ]; then
    currentTheme=$(basename "$(readlink -f "$currentLink")")
else
    currentTheme=""
fi

if [ ! -d "$THEMES_DIR" ]; then
    echo "$THEMES_DIR is not a directory"
    exit 1
fi

currentLine="󱝁 $currentTheme"
themes=()
themes+=("$currentLine")
for folder in "$THEMES_DIR"/*; do
    name=$(basename "$folder")
    if [ "$name" != "current" ] && [ "$name" != "$currentTheme" ] && [ "$name" != "size" ]; then
        themes+=("$name")
    fi
done


if [ ${#themes[@]} -eq 0 ]; then
    echo "No themes in $THEMES_DIR."
    exit 1
fi

selected=$(printf '%s\n' "${themes[@]}" | rofi -dmenu -l 20 -a 0 -selected-row 1 -p "Themes : " -theme $ROFI_THEME/list.rasi  )

if [ -z "$selected" ] || [[ "$selected" == "->"* ]]; then
    exit 0
fi

hyprlab theme -t $selected



