#!/bin/bash

MONITORS_CONF="$HOME/.config/hyprlab/hyprland/monitors_profile/current"


if [[ -z "$PRIMARY" ]];then 
    hyprlab message info "\$PRIMARY Env not found, taking PRIMARY from monitors.conf" 
    PRIMARY=$(grep '^\$PRIMARY=' "$MONITORS_CONF" | cut -d= -f2) 
    if [ -z "$PRIMARY" ]; then
        echo "Erreur : moniteur principal non trouvé dans monitors.conf"
        exit 1
    fi
    export PRIMARY
fi

envsubst < ~/.config/hyprlab/scripts/templates/swaync.json.template > ~/.config/swaync/config.json

if pgrep -x "swaync" >/dev/null; then
    hyprlab message info "Reloading Swaync"
    swaync-client -R -rs >/dev/null && hyprlab message ok "Swaync reloaded" || hyprlab message fail "Error while reloading Swaync"
fi