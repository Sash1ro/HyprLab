#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"
file="$HYPRLAB/hyprland/profiles/current/keybinds.conf"

keybinds=()
max_len=0
extra_space=3

# Close Rofi if already running
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi


while IFS= read -r line; do
    
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    if [[ "$line" =~ ^bind\ *= ]] ; then
     
        comment=""
        if [[ "$line" == *"#"* ]]; then
            comment="${line#*#}"
            comment="$(echo "$comment" | xargs)" 
        fi

        line_content="${line%%#*}"
        line_content="${line_content#bind = }"
        line_content="$(echo "$line_content" | xargs)"

       
        IFS=',' read -r key1 key2 action cmd <<< "$line_content"
        key1="$(echo "$key1" | xargs)"
        key2="$(echo "$key2" | xargs)"

   
        [[ "$key1" == '$mainMod' ]] && key1="SUPER"
        [[ "$key2" == '$mainMod' ]] && key2="SUPER"
        [[ "$key1" == '$shiftMod' ]] && key1="SHIFT"
        [[ "$key2" == '$shiftMod' ]] && key2="SHIFT"
        [[ "$key1" == '$mainMod SHIFT' ]] && key1="SUPER + SHIFT"
        [[ "$key1" == '$mainMod ALT' ]] && key1="SUPER + ALT"
       
        if [[ -z "$key1" ]]; then
            keys="$key2"
        elif [[ -z "$key2" ]]; then
            keys="$key1"
        else
            keys="$key1 + $key2"
        fi

       
        (( ${#keys} > max_len )) && max_len=${#keys}

      
        keybinds+=("$keys|$comment")
    fi
done < "$file"


for line in "${keybinds[@]}"; do
    keys="${line%%|*}"
    comment="${line#*|}"
    printf "%-$((max_len + extra_space))s -> %s\n" "$keys" "$comment"
done | rofi -dmenu -i -p "Keybinds : " -l 10 -theme "$ROFI_THEME/keyslist.rasi"
