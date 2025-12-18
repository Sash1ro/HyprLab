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
    random                     -> Set random anime png 
    distro                     -> Set distro logo
    custom                     -> Set a custom folder or file 
    current                    -> show actual fastfetch logo/dir path
    help                       -> Show this message
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
    exit 0
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
    random|distro|custom) mode ${@:-};;
    current) shift 1 && current;;
    "" | help) help && exit 0;;
    *) hyprlab message fail "Unknown option : $1" && help
    exit 1;;
esac


