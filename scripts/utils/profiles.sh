#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$HOME/.config/hyprlab/scripts/data/conf.env"
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

hProfiles="$HYPRLAB/hyprland/profiles/"
profiles=$hProfiles
mProfiles="$HYPRLAB/hyprland/monitors_profile"
monitor=false

help() {
cat <<EOF
Usage:
  profiles <command>

Commands :
    monitors, -m [options]  -> manage monitors profile
    set, -s <name>          -> set profile
    new, -n <name>          -> create new profile
    delete, -d <name>       -> delete a profile
    list, -l                -> list all profiles
    selected, -e            -> show the selected profile
    -h, --help              -> Show this message
EOF
}

list() {
    echo -e "Profiles :"
    find "$profiles" -mindepth 1 -maxdepth 1 \
    ! -name "current" ! -iname ".*" \
    -exec bash -c 'f=$(basename "$1"); echo "${f%.*}"' _ {} \;
}

verif() {
    local name="${1:-}"
    if [[ -z "$name" ]]; then
        hyprlab message fail "No profile name provided" && exit 1
    fi

    if [[ ! -d "$profiles/$name" && ! -f "$profiles/$name.conf"  ]]; then
        hyprlab message fail "Unknow profile : $name" && exit 1
    fi
}

selected() {
    local file=$(basename $(readlink "$profiles/current"))
    echo "${file%.*}"
}

set() {
    local name="${1:-}"
    verif $name
    if [[ "$profiles" == "$mProfiles" ]]; then
        name="$name".conf
    fi
    ln -sfn "$profiles/$name" "$profiles/current" 
    touch "$HOME/.config/hypr/hyprlock.conf"
    hyprctl reload && exit 0
} 

new() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        hyprlab message fail "No profile name provided" && exit 1
    fi

    if [[ -d "$profiles/$name" || -f "$profiles/$name.conf" ]]; then
        hyprlab message fail "Profile $name, already exist" && exit 1
    fi

    if [[ ! "$profiles" == "$mProfiles" ]]; then
        cp -r "$profiles/default" "$profiles/$name" 
    else 
        touch "$profiles/$name".conf
        "$SCRIPT_DIR/utils/screens.sh" "$profiles/$name".conf
    fi
    exit 0
} 

del() {
    local name="${1:-}"
    verif "$name"
    local selected=$(selected)
    echo $selected
    if [ "$selected" == "$name" ]; then
        set default
    fi

     if [[ ! "$profiles" == "$mProfiles" ]]; then
        rm -rf "$profiles/$name" 
    else 
        rm -rf "$profiles/$name.conf" 
    fi
    exit 0
} 



while [[ $# -gt 0 ]]; do
    case ${1:-} in 
        list | -l)list && exit 0;;
        selected | -e) selected && exit 0;;
        monitors | -m)shift 1 && profiles=$mProfiles;;
        set | -s)shift 1 && set "${@:-}";;
        new | -n)shift 1 && new "${@:-}";;
        delete | -d)shift 1 && del "${@:-}";;
        -h | --help | "") help && exit 0;;
        *)hyprlab message fail "Unknow option : $1" && help && exit 1;;
    esac
done