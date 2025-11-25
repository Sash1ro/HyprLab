#!/usr/bin/env bash
set -euo pipefail

source $HOME/.config/hyprlab/scripts/data/conf.env
CONFIG="$HOME/.config"
newCONFIG="$HYPRLAB/dots/"

for d in "$newCONFIG"/*; do
    if [[ -d "$d" ]]; then
        dirname=$(basename "$d")
        cp -r "$d/." "$CONFIG/$dirname/"
    fi
done

mkdir -p "$CONFIG/fish/themes"
mkdir -p "$CONFIG/cava/themes"

swww-daemon & waybar & swaync

find $HYPRLAB -type l -exec rm -f {} \;

#Tokyo Night by default
$SCRIPT_DIR/themes-switcher.sh -t "tokyo-night" || echo "Error while applying default theme"
$SCRIPT_DIR/waybar-switcher.sh -t "minimalist" || echo "Error while applying default theme"

