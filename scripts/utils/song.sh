#!/usr/bin/env bash

BLOCKED_PLAYERS=("firefox")
MAX_LEN=0

case ${1:-} in 
    none)MAX_LEN=999999;;
    "")MAX_LEN=30;;
    *)MAX_LEN=$1;;
esac


PLAYER=$(playerctl -l 2>/dev/null | head -n 1)

if [[ -z "$PLAYER" ]]; then
    echo "󰱶  No Music"
    exit 0
fi


status=$(playerctl -p "$PLAYER" status 2>/dev/null)


title=$(playerctl -p "$PLAYER" metadata title 2>/dev/null)
artist=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null)


if [[ -z "$title" ]]; then
    echo "󰱶  No Music"
    exit 0
fi

for blocked in "${BLOCKED_PLAYERS[@]}"; do
    if [[ "$PLAYER" == *"$blocked"* ]] && [[ "$title" != *"music"* ]]; then
        echo "󰱶  No Music"
        exit 0
    fi
done

if (( ${#artist} > MAX_LEN )); then
    artist="${artist:0:MAX_LEN}…"
fi

if (( ${#title} > MAX_LEN )); then
    title="${title:0:MAX_LEN}…"
fi

case "$status" in
    Playing) echo "󰽴  $artist - $title" ;;
    Paused)  echo "  $artist - $title" ;;
    *)       echo "  $artist - $title" ;;
esac

