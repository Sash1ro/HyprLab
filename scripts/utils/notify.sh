#!/usr/bin/env bash
set -euo pipefail

# ---------------- CONFIG ----------------
ENV_FILE="$HOME/.config/hyprlab/scripts/data/conf.env"
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

ICON_DIR="${ICON_DIR:-$ASSETS}"
SOUND_DIR="/usr/share/sounds/freedesktop/stereo"

show_help() {
cat <<EOF
Usage:
  hyprlab notify [notify-send args] [-i icon_name_or_path] [-s sound_file] content

Options:
  -i, --icon <name|path>   Icon for the notification (searched in ICON_DIR if relative)
  -s, --sound <file>       Sound to play along with the notification
  -h, --help               Show this help

Examples:
  hyprlab notify -u critical -i warning "Disk full"
  hyprlab notify -a System -t "Update" -i download "Download complete"
  hyprlab notify -i info -s beep.ogg "Hello world"
EOF
}

# ---------- DEFAULTS ----------
ICON=""
SOUND=""
ARGS=()

# ---------- PARSE OPTIONS ----------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--icon)
            shift
            [[ $# -eq 0 ]] && { echo "Missing icon"; exit 1; }
            ICON="$1"
            shift
            ;;
        -s|--sound)
            shift
            [[ $# -eq 0 ]] && { echo "Missing sound"; exit 1; }
            SOUND="$1"
            shift
            ;;
        -h|--help|"")
            show_help
            exit 0
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

play() {
    if [[ -n "$SOUND" ]]; then
    [[ ! -f "$SOUND" ]] && SOUND="$SOUND_DIR/$SOUND"
    if [[ -f "$SOUND" ]]; then
        if command -v paplay >/dev/null; then
            paplay "$SOUND" &
        elif command -v aplay >/dev/null; then
            aplay "$SOUND" &
        fi
    fi
fi
}

if [[ ${#ARGS[@]} -eq 0 ]] && [ -n "$SOUND" ]; then
    play
    exit 0
fi


[[ ${#ARGS[@]} -eq 0 ]] && { echo "Missing content"; exit 1; }
CONTENT="${ARGS[*]}"

# ---------- RESOLVE ICON ----------
if [[ -n "$ICON" && "$ICON" != /* ]]; then
    if [[ -f "$ICON_DIR/$ICON.svg" ]]; then
        ICON="$ICON_DIR/$ICON.svg"
    elif [[ -f "$ICON_DIR/$ICON.png" ]]; then
        ICON="$ICON_DIR/$ICON.png"
    fi
fi

# ---------- BUILD CMD ----------
CMD=(notify-send)
[[ -n "$ICON" ]] && CMD+=(-i "$ICON")
CMD+=("${ARGS[@]}")

# ---------- EXECUTE ----------
"${CMD[@]}"

# ---------- PLAY SOUND ----------
play

