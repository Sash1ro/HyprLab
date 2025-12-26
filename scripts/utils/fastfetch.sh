#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"
default="$ASSETS/ascii/opm.txt"
fastfetch="$THEMES_DIR/current/fastfetch"

help() {
cat <<EOF
Usage:
  fastfetch.sh <command>

Commands :
    default      -> Default Ascii (Saitama)
    distro       -> Distro Ascii Logo
    custom       -> Set a custom folder or file (image or txt)
    current      -> Show actual fastfetch logo/dir path
    help         -> Show this message
EOF
}

fail() {
    local m=$1
    hyprlab message fail "$1" && exit 1
}

success() {
    local m=$1
    hyprlab message ok "$1" && exit 0
}

valid() {
    local path=$1

    if [[ -z "$1" ]];then
        fail "No path provided"
    fi

    if [[ -f "$path" ]] || [[ -d "$path" ]]; then
        ln -sfn "$path" "$fastfetch"
        success "$path applied for fastfetch"
    else
        fail "No file or direcory : $path" 
    fi
}

mode() {
    local option=$1
    local path=${2:-}

    case $option in
        default) (ln -sfn "$default" "$fastfetch" && success "default logo for fastfetch") || fail "Error while applying default logo";;
        distro ) (rm $fastfetch && success "Distro logo for fastfetch" )|| fail "error while applying distro logo";;
        custom ) valid "$path" || fail "error while applying custom logo or dir";;
        "") help && exit 0;;
        *) fail "Invalid option : $1" && exit 1;;
    esac
    exit 0
}

current() {
    local link=$(readlink $fastfetch)
    if [[ -d $link ]]; then
        echo "$link"/*.png 
    elif [[ -z $link ]]; then
        if [ -z "$fastfetch" ]; then
            echo "distro ascii logo" 
        else 
            echo "$fastfetch"
        fi 
    else 
        echo "$link" 
    fi 
}

case ${1:-} in 
    default|distro|custom) mode ${@:-};;
    current) shift 1 && current;;
    "" | help) help && exit 0;;
    *) fail "Invalid option : $1" && exit 1;;
esac


