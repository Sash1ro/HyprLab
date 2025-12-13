#!/usr/bin/env bash
set -euo pipefail

# Load configuration
source "$HOME/.config/hyprlab/scripts/data/conf.env"

export PATH="$HYPRLAB/bin:$PATH"

swww-daemon &>/dev/null &
waybar &>/dev/null &
swaync &>/dev/null &

# Apply default themes
"$SCRIPT_DIR/utils/themes-switcher.sh" -t "tokyo-night" || echo "Error while applying default theme"
"$SCRIPT_DIR/utils/themes-switcher.sh" -s 1 || echo "Error while applying default size profile"
"$SCRIPT_DIR/utils/waybar-switcher.sh" -t "minimalist" || echo "Error while applying default theme"
