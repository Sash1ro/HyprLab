#!/usr/bin/env bash

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')

getStatus() {
    if [ "$HYPRGAMEMODE" = 1 ]; then
        echo "false"
    else
        echo "true"
    fi
    exit 0
}

activate() {
            hyprctl --batch "\
            keyword animations:enabled 0;\
            keyword animation borderangle,0; \
            keyword decoration:shadow:enabled 0;\
            keyword decoration:blur:enabled 0;\
	        keyword decoration:fullscreen_opacity 1;\
            keyword general:gaps_in 0;\
            keyword general:gaps_out 0;\
            keyword general:border_size 1;\
            keyword decoration:rounding 0"
        hyprlab notify normal Hyprlab Options "Gamemode ON" -i adjust
        hyprlab message ok "Gamemode ON"
        exit 0
}

desactivate() {
    hyprlab notify normal Hyprlab Options "Gamemode OFF" -i adjust
    hyprlab message ok "Gamemode OFF"
    hyprctl reload
    exit 0
}

toggle() {
    if [ "$HYPRGAMEMODE" = 1 ] ; then
        activate
    else
        desactivate
    fi
}

help() {
cat <<EOF
Usage:
  $(basename $0) <command>

Commands :
    status        -> Get current state
    toggle        -> Toggle gamemode
    on            -> Turn on gamemode
    off           -> Turn off gamemode
    -h, --help    -> Show this message
EOF
}

case $1 in 
    toggle) toggle;;
    on) activate;;
    off) desactivate;;
    status) getStatus;;
    "" | -h | --help) help && exit 0;;
    *) hyprlab message fail "Unknown options : $1" && help
    exit 1;;
esac