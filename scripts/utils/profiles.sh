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
  profiles <command> [options]

Commands :
    set <name>              -> set profile
    new <name>              -> create new profile
    delete <name>           -> delete a profile
    list                    -> list all profiles
    selected                -> show the selected profile
    help                    -> Show this message
Options: 
    monitors, -m            -> Monitors profiles
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
    touch "$HOME/.config/hypr/hyprlock.conf" >/dev/null
    hyprlab message ok "Profile $name applied"
    hyprctl -q reload && exit 0
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
    hyprlab message ok "Profile $name created"
    exit 0
} 

del() {
    local name="${1:-}"
    verif "$name"
    local selected=$(selected)
    if [ "$selected" == "$name" ]; then
        set default
    fi

     if [[ ! "$profiles" == "$mProfiles" ]]; then
        rm -rf "$profiles/$name" 
    else 
        rm -rf "$profiles/$name.conf" 
    fi
    hyprlab message ok "Profile $name deleted"
    exit 0
} 

for arg in "$@"; do
    case "$arg" in
        -m|monitors)
            profiles=$mProfiles
            [[ "$1" == "$arg" ]] && shift
            break
            ;;
    esac
done


case ${1:-} in 
        list)list && exit 0;;
        selected) selected && exit 0;;
        set)shift 1 && set "${@:-}";;
        new)shift 1 && new "${@:-}";;
        delete)shift 1 && del "${@:-}";;
        help | "") help && exit 0;;
        *)hyprlab message fail "Unknow option : $1" && help && exit 1;;
esac
