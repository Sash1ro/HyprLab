#!/usr/bin/env bash
set -euo pipefail

# Load configuration
source "$HOME/.config/hyprlab/scripts/data/conf.env"

swww-daemon &>/dev/null &
waybar &>/dev/null &
swaync &>/dev/null &

find "$HYPRLAB" -type l -exec rm -f {} \; || true

# Apply default themes
"$SCRIPT_DIR/utils/themes-switcher.sh" -t "tokyo-night" || echo "Error while applying default theme"
"$SCRIPT_DIR/utils/waybar-switcher.sh" -t "minimalist" || echo "Error while applying default theme"
