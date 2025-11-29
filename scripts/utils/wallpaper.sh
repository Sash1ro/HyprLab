#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"

help() {
cat <<EOF
Usage:
  $(basename "$0") <command>

Commands :
    add <file path> [options]   -> copy your wallpaper into hyprlab wallpapers folder and theme if provided
    remove <filename> (theme)   -> remove a wallpaper from everywhere or only from a theme if provided
    set <file path>             -> set the wallpaper for the current theme
    -h, --help                  -> Show this message
Options :
    -t, --theme                 -> theme name
    -n, --name                  -> file name
    -r, --remove                -> remove the original file
EOF
}

add() {
    local choice=${1:-}

    if [[ -z "$choice" ]]; then
        hyprlab message fail "No file provided"
        exit 1
    fi

    if [[ ! -f "$choice" ]]; then
        hyprlab message fail "This file doesn't exist"
        exit 1
    fi

    local filename
    filename=$(basename "$choice")
    local remove=0
    local success=0
    local name=""
    local theme=""

    shift 1
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--name) name=$2; shift 2;;
            -t|--theme) theme=$2; shift 2;;
            -r|--remove) remove=1; shift 1;;
            *) hyprlab message fail "Unknown option: $1"; help; exit 1;;
        esac
    done

    if [[ -n "$name" ]]; then
        filename="$name.${filename##*.}"
    fi

    if [[ -f "$HYPRLAB/wallpapers/$filename" ]]; then
        hyprlab message fail "$filename is already in wallpapers"
    else
        success=1
        cp "$choice" "$HYPRLAB/wallpapers/$filename" \
            && hyprlab message ok "Successfully added $filename to wallpapers" \
            || { hyprlab message fail "Error while copying $filename"; exit 1; }
    fi

    if [[ -n "$theme" ]]; then
        if [[ ! -d "$THEMES_DIR/$theme" ]]; then
            hyprlab message fail "Unknown theme: $theme"
            exit 1
        fi

        local theme_path="$THEMES_DIR/$theme/wallpapers"
        mkdir -p "$theme_path"

        if [[ -f "$theme_path/$filename" ]]; then
            hyprlab message fail "$filename is already in $theme"
        else
            success=1
            cp "$choice" "$theme_path/$filename" \
                && hyprlab message ok "Successfully added $filename to theme $theme" \
                || { hyprlab message fail "Error while copying $filename to theme"; exit 1; }
        fi
    fi

    if [[ $remove -eq 1 && $success -eq 1 ]]; then
        rm -f "$choice" \
            && hyprlab message ok "Successfully removed original file: $choice" \
            || hyprlab message fail "Error while removing original file: $choice"
    fi
}

remove() {
    local filename=${1:-}
    local theme=${2:-}

    if [[ -z "$filename" ]]; then
        hyprlab message fail "No filename provided"
        exit 1
    fi

    if [[ -n "$theme" ]]; then
        local theme_path="$THEMES_DIR/$theme/wallpapers"
        if [[ ! -d "$THEMES_DIR/$theme" ]]; then
            hyprlab message fail "Unknown theme: $theme"
            exit 1
        fi

        find "$theme_path" -type f -name "$filename" -exec rm -f {} \; && hyprlab message ok "Removed $filename from $theme"

    else
        find "$THEMES_DIR" -type f -name "$filename" -exec rm -f {} \; && hyprlab message ok "Removed $filename from all themes"
        rm -f "$HYPRLAB/wallpapers/$filename" && hyprlab message ok "Removed $filename from wallpapers"
    fi
}

setW() {
    local file=${1:-}
    local filename=$(basename $file)
    local theme="$THEMES_DIR/current"
    local current="$theme/wallpaper"

    if [[ -z "$file" ]]; then
        hyprlab message fail "No file provided"
        exit 1
    fi

    if [[ -f "$file" ]]; then
        ln -sf "$file" "$current"
        swww img $current --transition-type grow --transition-fps 60 >/dev/null \
             && hyprlab notify normal Hyprlab "Wallpaper Updated" "Actual : $filename" -i picture \
             || hyprlab message fail "Error while applying $filename"
    else 
        hyprlab message fail "$filename dont exist" && exit 1
    fi
}

case "${1:-}" in
    add)
        shift 1
        add "$@"
        ;;
    remove)
        shift 1 
        remove "$@"
        ;;
    set)
        shift 1
        setW "$@"
        ;;
    ""|-h|--help)
        help
        exit 0
        ;;
    *)
        hyprlab message fail "Unknown command: $1"
        help
        exit 1
        ;;
esac
