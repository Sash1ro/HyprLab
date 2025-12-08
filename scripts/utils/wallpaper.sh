#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"

help() {
cat <<EOF
Usage:
  $(basename "$0") <command>

Commands :
    add <file path> [options]       -> copy your wallpaper into hyprlab wallpapers folder and theme if provided
    add-all <folder path> [-t, -r]  -> add all wallpaper from a folder
    remove <filename> (theme)       -> remove a wallpaper from everywhere or only from a theme if provided
    set <file path>                 -> set the wallpaper for the current theme
    clear                           -> clear cache used for rofi menu
    -h, --help                      -> Show this message
Options :
    -t, --theme                     -> theme name
    -n, --name                      -> file name
    -r, --remove                    -> remove the original file
EOF
}

add() {
    local choice=${1:-}
    local filename
    filename=$(basename "$choice")

    if [[ -z "$choice" ]]; then
        hyprlab message fail "No file provided"
        exit 1
    fi

    if [[ ! -f "$choice" ]]; then
        if [[ -f "$HYPRLAB/wallpapers/$filename" ]]; then
            choice="$HYPRLAB/wallpapers/$filename"
        else
            hyprlab message fail "This file doesn't exist"
            exit 1
        fi
    fi

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

    local link=$(readlink $theme)
    local themeName=$(basename $link)

    if [[ -z "$file" ]]; then
        hyprlab message fail "No file provided"
        exit 1
    fi

    if [[ -f "$file" ]]; then
        ln -sf "$file" "$current"

        if [[ "$themeName" == "matugen" ]]; then
            (matugen image "$current" >/dev/null \
            && "$SCRIPT_DIR/others/updateLink.sh" \
            && "$SCRIPT_DIR/others/setFish.sh" \
            && hyprlab reload \
            && hyprlab notify normal Hyprlab "Wallpaper Updated" "Actual : $filename" -i image) \
            || hyprlab message fail "Error while applying $filename"

            hyprlab message info "Reloading Neovim"
            for pid in $(pgrep nvim); do
                kill -USR1 "$pid"
            done
        else 
            (swww img "$current" --transition-type grow --transition-fps 60 >/dev/null \
            && hyprlab notify normal Hyprlab "Wallpaper Updated" "Actual : $filename" -i image) \
            || hyprlab message fail "Error while applying $filename"
        fi
    else 
        hyprlab message fail "no file : $filename" && exit 1
    fi
}

add_all() {
    local choice=${1:-}
    shift

    if [[ -z "$choice" ]]; then
        hyprlab message fail "No folder provided"
        exit 1
    fi

    if [[ ! -d "$choice" ]]; then
        hyprlab message fail "This folder doesn't exist"
        exit 1
    fi

    local remove=0
    local theme=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -t|--theme) theme=$2; shift 2;;
            -r|--remove) remove=1; shift;;
            *) hyprlab message fail "Unknown option: $1"; help; exit 1;;
        esac
    done

    local opts=()
    [[ $remove -eq 1 ]] && opts+=("-r")
    [[ -n $theme ]] && opts+=("-t" "$theme")

    local extensions="jpg|jpeg|png|bmp|webp"

    for fichier in "$choice"/*; do
        if [[ -f "$fichier" ]]; then
            ext="${fichier##*.}"
            ext="${ext,,}"
            if [[ $ext =~ ^($extensions)$ ]]; then
                add "$fichier" "${opts[@]}"
            fi
        fi
    done
}

clear() {
    local cache="$SCRIPT_DIR/cache/cached_imgs"
    rm -rf $cache/*
}

case "${1:-}" in
    add)
        shift 1
        add "$@"
        ;;
    add-all)
        shift 1
        add_all "$@"
        ;;
    clear)
        shift 1
        clear
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
