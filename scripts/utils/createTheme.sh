#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"
TEMPLATES="$HYPRLAB/themes/.templates"

# if [ -z "$COLORS" ] || [ ! -f "$COLORS" ]; then
#     hyprlab message fail "No file provided, you need to provide a valid JSON"
#     exit 1
# fi

help() {
cat <<EOF
Usage:
  createTheme.sh <command>

Commands :
    help                       -> Show this message
EOF
}

init() {
    local NAME=${1:-}
    local THEME="$HYPRLAB/themes/$NAME"

    if [ -z "$NAME" ]; then
        hyprlab message fail "Please provide a theme name"
        exit 1
    fi

    if [ -d "$THEME" ]; then
        hyprlab message fail "$NAME already exist"
        exit 1
    fi

    mkdir $THEME
    cp "$TEMPLATES/colors.json" "$THEME/colors.json"

    hyprlab message ok "Theme $NAME created, now pls provide colors in the colors.json, \n located : $THEME"
    exit 0
}

update() {
    local FILE=${1:-}
    local COLORS=${2:-}
    local NAME=$(basename $FILE)
    
    hyprlab message info "Updating $NAME"

    #HEX VALUES
    while IFS== read -r key value; do
        sed -i "s/{hex.$key}/$value/g" "$FILE"
        sed -i "s/{hhex.$key}/${value#\#}/g" "$FILE"
    done < <(jq -r '.hex | to_entries[] | "\(.key)=\(.value)"' "$COLORS")

    #RGB VALUES
    while IFS== read -r key value; do
        sed -i "s/{rgb.$key}/$value/g" "$FILE"
    done < <(jq -r '.rgb | to_entries[] | "\(.key)=\(.value)"' "$COLORS")

    hyprlab message ok "$NAME Updated"
}

tcopy() {
    local NAME=${1:-}
    local THEME="$HYPRLAB/themes/$NAME"

    for d in "$TEMPLATES/theme"/*; do
        if [[ -d "$d" ]]; then
            local dirname=$(basename "$d")
            mkdir -p "$THEME/$dirname"
            cp -r "$d/." "$THEME/$dirname/"
        fi
    done

    for f in "$TEMPLATES/theme"/*; do
        if [[ -f "$f" ]]; then
            local filename=$(basename "$f")
            cp -r "$f" "$THEME/$filename"
        fi
    done
}

make() {
    local NAME=${1:-}
    local THEME="$HYPRLAB/themes/$NAME"

    if [ -z "$NAME" ]; then
        hyprlab message fail "Please provide a theme name"
        exit 1
    fi

    if [ ! -d "$THEME" ]; then
        hyprlab message fail "$NAME is not a valid theme"
        exit 1
    fi

    local SIZE=$(ls -1 $THEME | wc -l)

    if [ $SIZE -gt 1 ]; then
        hyprlab message fail "$NAME already made or is invalid"
        exit 1
    fi

    tcopy $NAME

    for f in "$THEME"/*; do
        local file="$f"
        local filename=$(basename "$f")
        
        if [[ $filename == *"wallpapers"* ]]; then
            continue 
        fi

        if [ -d "$f" ]; then
            file=$(find $f -maxdepth 1 -type f | head -n 1)
        fi

        update "$file" "$THEME/colors.json"
    done
}

case ${1:-} in
    init)shift && init ${@:-};;
    make)shift && make ${@:-};;
    "" | help | -h) help && exit 0;;
    *) hyprlab message fail "Invalid option : $1" && exit 1;;
esac