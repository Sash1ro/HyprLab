#!/usr/bin/env bash
set -u

CONF_FILE="$HOME/.config/hyprlab/scripts/data/conf.env"
[ -f "$CONF_FILE" ] && source "$CONF_FILE"

CACHE_DIR="$SCRIPT_DIR/cache"
HISTORY_FILE="$CACHE_DIR/calc-history"

mkdir -p "$CACHE_DIR"
touch "$HISTORY_FILE"

if ! command -v qalc &> /dev/null; then
    echo -en "\0message\x1fError: 'qalc' is not installed.\n"
    exit 1
fi

run () {
    if [ "$*" == "Clear History" ]; then
        truncate -s 0 "$HISTORY_FILE"
        hyprlab notify -a ROFI CALC "History cleared" --icon user-trash
        exit 0
    fi

    if [ -z "$*" ]; then
        echo -en "\0prompt\x1fCalc : \n"
        echo -en "\0message\x1fPress RETURN to validate\n"

        if [ -s "$HISTORY_FILE" ]; then
            echo "Clear History"
            tac "$HISTORY_FILE"
        fi
        exit 0
    fi

    INPUT="$*"

    if [[ "$INPUT" == *" = "* ]]; then
        COPY_PART="${INPUT##* = }"
        COPY_PART="${COPY_PART#"${COPY_PART%%[![:space:]]*}"}"   # left trim
        COPY_PART="${COPY_PART%"${COPY_PART##*[![:space:]]}"}"   # right trim
        wl-copy "$COPY_PART"
        exit 0
    fi

    RESULT=$(qalc -t "$INPUT" 2>/dev/null)

    if [ -n "$RESULT" ]; then
        NEW_ENTRY="$INPUT = $RESULT"
        LAST_ENTRY=$(tail -n 1 "$HISTORY_FILE" 2>/dev/null || echo "")

        [ "$LAST_ENTRY" != "$NEW_ENTRY" ] && echo "$NEW_ENTRY" >> "$HISTORY_FILE"

        if [ "$(wc -l < "$HISTORY_FILE")" -gt 10 ]; then
            tail -n 10 "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
        fi

        echo -en "\0message\x1fResult: $RESULT\n"
        echo "Clear History"
        tac "$HISTORY_FILE"
    else
        echo -en "\0message\x1fInvalid Calculation\n"
    fi
}

show() {
    rofi -show calc \
    -modes "calc:$SCRIPT_DIR/menu/calc.sh" \
    -theme "~/.config/hyprlab/rofi/themes/list.rasi"  -matching regex
}

case ${1:-} in 
    show) show;;
    *) run "${@:-}";;
esac