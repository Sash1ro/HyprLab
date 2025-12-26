#!/usr/bin/env bash
source "$HOME/.config/hyprlab/scripts/data/conf.env"

#KILL ROFI
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi  

options=("$HYPRLAB/hyprland/profiles/current/"*.conf)
target=""   
target=$(readlink -f "$HYPRLAB/hyprland/monitors_profile/current")

declare -A map

for conf in "${options[@]}"; do
    map[" $(basename "${conf%.conf}")"]="$conf"
done

map[" monitors"]="$target"

choice
choice=$(
printf '%s\n' "${!map[@]}" \
| sort \
| rofi -dmenu -i -p "Hyprland : " -l 12 -theme "$ROFI_THEME/list.rasi"
)   

selected_file=${map[$choice]}
if [[ -f "$selected_file" ]]; then
    $TERMINAL --class float nvim "$selected_file"
fi
