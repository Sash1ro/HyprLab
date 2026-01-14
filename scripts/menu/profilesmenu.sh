#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

profile_menu() {
    local profiles=("$HYPRLAB/hyprland/profiles/global/"*)
    local name;local selected;local index
    declare -A map

    for i in "${!profiles[@]}"; do
        conf="${profiles[i]}"
        [ -L "$conf" ] && continue

        name=$(basename "$conf")
        name=${name%.conf}
        selected=$(hyprlab profile selected)

        if [ "$name" == "$selected" ]; then
            index=$((i))
            map[" $name"]="$name"
        else
            map["󰘼 $name"]="$name"
        fi
    done

    local sel=0
    [ $index -eq 0 ] && sel=1

    choice=$(
        printf '%s\n' "${!map[@]}" \
        | sort \
        | rofi -dmenu -i -p "System : " -l 12 -a $index -selected-row $sel -theme "$ROFI_THEME/list.rasi"
    )

    if [ ! -z "$choice" ]; then 
        hyprlab profile set ${map[$choice]}
    fi

}

monitor_menu() {
    local profiles=("$HYPRLAB/hyprland/profiles/monitors/"*)
    local name;local selected;local index
    declare -A map

    for i in "${!profiles[@]}"; do
        conf="${profiles[i]}"
        [ -L $conf ] && continue

        name=$(basename "$conf")
        name=${name%.conf}
        selected=$(hyprlab profile -m selected)
        

        if [ "$name" == "$selected" ]; then
            index=$((i))
            map[" $name"]="$name"
        else
            map["󰘼 $name"]="$name"
        fi
    done

    local sel=0
    [ $index -eq 0 ] && sel=1

    choice=$(
        printf '%s\n' "${!map[@]}" \
        | sort \
        | rofi -dmenu -i -p "Monitors : " -l 12 -a $index -selected-row $sel -theme "$ROFI_THEME/list.rasi"
    )

    if [ ! -z "$choice" ]; then 
        hyprlab profile -m set ${map[$choice]}
    fi

}


p=" System profiles"
m="󰍹 Monitors profiles"
s="$p\n$m"
choice=$(echo -e "$s" | rofi -dmenu -i -p "Profiles :" -theme $ROFI_THEME/list.rasi)

case $choice in
    $p)profile_menu;;
    $m)monitor_menu;;
    *) exit 0
esac
