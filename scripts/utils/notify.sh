#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$HOME/.config/hyprlab/scripts/data/conf.env"
DEFAULT_ICON_DIR="$HOME/.config/hyprlab/assets"

[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

ICON_DIR="${ICON_DIR:-$DEFAULT_ICON_DIR}"

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

show_help() {
cat <<EOF

Usage:
  $(basename $0) <urgency> <app> <title> <content> [options]

Urgency levels:
  low | normal | crit

Examples:
  $(basename $0) normal Firefox "Download Complete" "Your file is ready" --icon download
  $(basename $0) crit System "Error" "Something happened" --icon warning --sound /path/beep.ogg

Options:
  -i, --icon <name>   Use icon from $ICON_DIR (<name>.svg / .png)
  -s, --sound <file>  Play a sound with the notification
  -h, --help          Show this help
EOF
}

if [[ $# -lt 4 ]]; then
    show_help
    exit 1
fi

URGENCY="$1"
APP="$2"
TITLE="$3"
CONTENT="$4"

shift 4

PLAY_SOUND=""
ICON=""

[[ ! -d "$ICON_DIR" ]] && echo -e "${YELLOW}Warning:${RESET} Icon directory missing: $ICON_DIR"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--icon)
            ICON_NAME="$2"
            ICON="$ICON_DIR/$ICON_NAME.svg"
            shift 2
            ;;
        -s|--sound)
            PLAY_SOUND="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option:${RESET} $1"
            exit 1
            ;;
    esac
done

case "$URGENCY" in
    low)    URG_FLAG="-u low" ;;
    crit)   URG_FLAG="-u critical" ;;
    *)      URG_FLAG="" ;;  # normal
esac


if [[ -n "$ICON" ]]; then
    if [[ ! -f "$ICON" ]]; then
        if [[ -f "${ICON%.svg}.png" ]]; then
            ICON="${ICON%.svg}.png"
        else
            echo -e "${YELLOW}Warning:${RESET} Icon not found, using default."
            ICON="$ICON_DIR/hypr.svg"
        fi
    fi
fi

if [[ -n "$ICON" ]]; then
    notify-send $URG_FLAG -a "$APP" "$TITLE" "$CONTENT" -i "$ICON"
else
    notify-send $URG_FLAG -a "$APP" "$TITLE" "$CONTENT"
fi

if [[ -n "$PLAY_SOUND" ]]; then
    if command -v paplay >/dev/null; then
        paplay "$PLAY_SOUND" &
    elif command -v aplay >/dev/null; then
        aplay "$PLAY_SOUND" &
    fi
fi

