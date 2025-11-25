#!/usr/bin/env bash
set -euo pipefail

# Load configuration
source "$HOME/.config/hyprlab/scripts/data/conf.env"

CONFIG="$HOME/.config"

swww-daemon &>/dev/null &
waybar &>/dev/null &
swaync &>/dev/null &

find "$HYPRLAB" -type l -exec rm -f {} \; || true

# Apply default themes
"$SCRIPT_DIR/themes-switcher.sh" -t "tokyo-night" || echo "Error while applying default theme"
"$SCRIPT_DIR/waybar-switcher.sh" -t "minimalist" || echo "Error while applying default theme"
