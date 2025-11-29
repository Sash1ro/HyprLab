#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$HOME/.config/hyprlab/scripts/data/conf.env"
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

help() {
cat <<EOF
Usage:
  options <command>

Commands :
    gamemode, -g    -> manage gamemode
    nightmode, -n   -> manage nightmode
    vibrant, -v     -> manage digital vibrant
    bluetooth, -b   -> manage bluetooth 
    -h, --help      -> Show this message
EOF
}

case $1 in 
    gamemode | -g) shift 1 && "$SCRIPT_DIR/options/gamemode.sh" "${@:-}";;
    nightmode | -n) shift 1 && "$SCRIPT_DIR/options/nightMode.sh" "${@:-}";;
    vibrant | -v) shift 1 && "$SCRIPT_DIR/options/toggleVibrant.sh" "${@:-}";;
    bluetooth | -b) shift 1 && "$SCRIPT_DIR/options/toggleBluetooth.sh" "${@:-}";;
    "" | -h | --help) help && exit 0;;
    *)hyprlab message fail "Unknown options : $1" && help 
    exit 1;;
esac