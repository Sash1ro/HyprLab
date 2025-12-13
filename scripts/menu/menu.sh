#!/usr/bin/env bash
source "$HOME/.config/hyprlab/scripts/data/conf.env"

#KILL ROFI
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

#OPTIONS
clip=" Clipboard"
capture=" Capture"
opt=" Options"
prof=" Profiles" 
tam=" TaskManager"
keys="󰌌 Keybinds"
power="⏻ Power"
lofi="󰎇 Online Music"
emoji="󰱰 Emoji Picker"
custom=" Customizations"

prompt="$clip
$capture
$tam
$lofi
$emoji
$prof
$opt
$keys
$power
$custom"

#POP ROFI
v=$(echo -e "$prompt" | rofi -dmenu -l 20 -i -p "MENU : " -theme $ROFI_THEME/list.rasi)

custom_menu() {
    local theme=" Themes"
    local waybar=" Waybar themes"
    local wallpaper="󰸉 Wallpapers"
    local wallpaperall="󰸉 All Wallpapers"
    local p="$theme\n$waybar\n$wallpaper\n$wallpaperall"

    local v=$(echo -e "$p" | rofi -dmenu -i -p "Customizations : " -theme $ROFI_THEME/list.rasi)

    case $v in 
        "$theme") "$SCRIPT_DIR/menu/theme-picker.sh";;
        "$wallpaper") "$SCRIPT_DIR/menu/wallpaper-switcher.sh";;
        "$wallpaperall") "$SCRIPT_DIR/menu/wallpaper-switcher.sh" all;;
        "$waybar") "$SCRIPT_DIR/menu/waybar-picker.sh";;
        *)exit 0
    esac
}

other_menu() {
    local vibrant="󰌁 Turn vibrant on"
    if [[ "$($SCRIPT_DIR/options/toggleVibrant.sh status)" == "true" ]]; then
        vibrant="󰹊 Turn vibrant off"
    fi

    local gamemode="󰊗 Turn gamemode on"
    if [[ "$($SCRIPT_DIR/options/gamemode.sh status)" == "true" ]]; then
        gamemode="󰊗 Turn gamemode off"
    fi
    local clip="󱘜 Clear Clipboard"

    local p="$vibrant\n$gamemode\n$clip"
    local v=$(echo -e "$p" | rofi -dmenu -i -p "Other : " -theme $ROFI_THEME/list.rasi)

    case $v in 
        "$vibrant") "$SCRIPT_DIR/options/toggleVibrant.sh" toggle;;
        "$gamemode") "$SCRIPT_DIR/options/gamemode.sh" toggle;;
        "$clip") "$SCRIPT_DIR/menu/clip.sh" w;;
        *)exit 0
    esac
}

hypr_menu() {
    local options=("$HYPRLAB/hyprland/profiles/current/"*.conf)
    local target
    target=$(readlink -f "$HYPRLAB/hyprland/monitors_profile/current")

    declare -A map

    for conf in "${options[@]}"; do
        map[" $(basename "${conf%.conf}")"]="$conf"
    done

    map[" monitors"]="$target"

    local choice
    choice=$(
        printf '%s\n' "${!map[@]}" \
        | sort \
        | rofi -dmenu -i -p "Hyprland : " -l 12 -theme "$ROFI_THEME/list.rasi"
    )

    local selected_file=${map[$choice]}
    if [[ -f "$selected_file" ]]; then
        $TERMINAL --class float nvim "$selected_file"
    fi
}

profile_menu() {
    local profiles=("$HYPRLAB/hyprland/profiles/"*)
    local name;local selected
    declare -A map

    for conf in "${profiles[@]}"; do 
        [ -L $conf ] && continue


        name=$(basename "$conf")
        selected=$(hyprlab profile selected)
        

        if [ "$name" == "$selected" ]; then
            map[" $name"]="$name"
        else
            map["󰘼 $name"]="$name"
        fi
    done

    choice=$(
        printf '%s\n' "${!map[@]}" \
        | sort \
        | rofi -dmenu -i -p "System : " -l 12 -theme "$ROFI_THEME/list.rasi"
    )

    if [ ! -z "$choice" ]; then 
        hyprlab profile set ${map[$choice]}
    fi

}

monitor_menu() {
    local profiles=("$HYPRLAB/hyprland/monitors_profile/"*)
    local name;local selected
    declare -A map

    for conf in "${profiles[@]}"; do 
        [ -L $conf ] && continue


        name=$(basename "$conf")
        name=${name%.conf}
        selected=$(hyprlab profile -m selected)
        

        if [ "$name" == "$selected" ]; then
            map[" $name"]="$name"
        else
            map["󰘼 $name"]="$name"
        fi
    done

    choice=$(
        printf '%s\n' "${!map[@]}" \
        | sort \
        | rofi -dmenu -i -p "Monitors : " -l 12 -theme "$ROFI_THEME/list.rasi"
    )

    if [ ! -z "$choice" ]; then 
        hyprlab profile -m set ${map[$choice]}
    fi

}

prof_menu() {
    local p=" System profiles"
    local m="󰍹 Monitors profiles"
    local s="$p\n$m"
    local choice
    choice=$(echo -e "$s" | rofi -dmenu -i -p "Profiles :" -theme $ROFI_THEME/list.rasi)

    case $choice in
        $p)profile_menu;;
        $m)monitor_menu;;
        *) exit 0
    esac
}

opt_menu() {
    local hypr=" Hyprland"
    local wifi=" WIFI"
    local conn="󰈀 Internet"
    local bt="󰂯 Bluetooth"
    local sound=" Sound"
    local other=" Others"

    local p="$hypr\n$wifi\n$conn\n$bt\n$sound\n$other"

    local v=$(echo -e "$p" | rofi -dmenu -i -p "Options : " -theme $ROFI_THEME/list.rasi)

    case $v in
    "$hypr")hypr_menu;;
    "$wifi") "$SCRIPT_DIR/menu/wifi.sh" &;;
    "$conn")pkill nm-connection-editor && hyprctl dispatch exec nm-connection-editor || hyprctl dispatch exec nm-connection-editor;;
    "$bt")pkill blueman-manager && hyprctl dispatch exec blueman-manager || hyprctl dispatch exec blueman-manager;;
    "$sound")pkill pavucontrol && hyprctl dispatch exec pavucontrol || hyprctl dispatch exec pavucontrol;;
    "$other")other_menu;;
    *)exit 0
    esac
}


#SETTING UP OPTIONS 
case $v in
    "$clip") "$SCRIPT_DIR/menu/clip.sh";;

    "$emoji")"$SCRIPT_DIR/menu/emoji-picker.sh";;

    "$lofi") "$SCRIPT_DIR/menu/lofi.sh";;

    "$keys") "$SCRIPT_DIR/menu/keybinds.sh";;

    "$capture") "$SCRIPT_DIR/menu/capture.sh";;

    "$tam") "$SCRIPT_DIR/apps/btop.sh";;

    "$opt") opt_menu;;

    "$prof") prof_menu;;

    "$custom") custom_menu;;

    "$power") wlogout -b 4;;
    *) exit 0
esac


