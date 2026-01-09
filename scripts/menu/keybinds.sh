#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"

json=$(hyprctl -j binds)

max_len=0
extra_space=5
keybinds=()

# Close Rofi if already running
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

mapfile -t items < <(jq -c '.[]' <<< "$json")

for item in "${items[@]}"; do
    mod=$(jq -r '.modmask' <<< "$item")
    key=$(jq -r '.key' <<< "$item")
    desc=$(jq -r '.description' <<< "$item")

    case ${mod:-} in 
        64) mod="SUPER";;
        65) mod="SUPER + SHIFT";;
        72) mod="SUPER + ALT";;
        1)  mod="SHIFT";;
        ""|0) mod="";;
    esac 

    case ${key:-} in
        ampersand)key="1";;
        eacute)key="2";;  
        quotedbl)key="3";; 
        apostrophe)key="4";;  
        parenleft)key="5";;  
        egrave)key="6";; 
        minus)key="7";; 
        underscore)key="8";;  
        ccedilla)key="9";;
        agrave)key="10";;
        mouse:272)key="LMB";;
        mouse:273)key="RMB";;
    esac 

 
    if [[ -n "$mod" ]]; then              
        res="<span style='italic'>$mod</span> + $key"
    else
        res="<span style='normal'>$key</span>"
    fi

    (( ${#res} > max_len )) && max_len=${#res}

    keybinds+=("$res|$desc")
done

width=$((max_len + extra_space))

for line in "${keybinds[@]}"; do
    keys="${line%%|*}"
    comment="${line#*|}"
    printf "%-${width}s -> %s\n" "$keys" "$comment"
done | rofi -dmenu -markup-rows -i -p "Keybinds : " -l 10 -theme "$ROFI_THEME/keyslist.rasi"
