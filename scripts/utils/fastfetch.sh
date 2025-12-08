#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"
anime="$HYPRLAB/assets/fastfetch"
fastfetch="$HYPRLAB/themes/current/fastfetch"

help() {
cat <<EOF
Usage:
  fastfetch.sh <command>

Commands :
    logo, -l <options>         -> manage fastfetch logo
    current, -c                -> show actual fastfetch logo/dir path
    -h, --help                 -> Show this message

Options :
    random, -r             -> random anime png
    distro, -d             -> distro logo
    custom, -c <path>      -> your custom logo or dir
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
        success "$path for fastfetch"
    else
        fail "No file or direcory : $path" 
    fi
}

result=""
mode() {
    local option=$1
    local path=${2:-}

    case $option in
        random | -r) (ln -sfn "$anime" "$fastfetch" && success "Random anime logo for fastfetch") || fail "Error while setting random anime logo";;
        distro | -d) (rm $fastfetch && success "Distro logo for fastfetch" )|| fail "error while setting distro logo";;
        custom | -c) valid "$path" || fail "error while setting custom logo or dir";;
        "") help && exit 0;;
        *) hyprlab message fail "Unknown option : $1" && help
        exit 1;;
    esac
}

current() {
    local link=$(readlink $fastfetch)
    if [[ -d $link ]]; then
        echo "$link"/*.png && exit 0
    elif [[ -z $link ]]; then
        echo "distro ascii logo" && exit 0
    fi
    echo "$link" && exit 0
}

case ${1:-} in 
    logo | -l) shift 1 && mode "${@:-}";;
    current | -c) shift 1 && current;;
    "" | -h | --help) help && exit 0;;
    *) hyprlab message fail "Unknown option : $1" && help
    exit 1;;
esac


