#!/usr/bin/env bash
source "$HOME/.config/hyprlab/scripts/data/conf.env"
export PATH="$SCRIPT_DIR/bin:$PATH"

videoFolder=$(xdg-user-dir VIDEOS)

recording_flag="$SCRIPT_DIR/cache/wf-recorder-active"

if [ ! -d $videoFolder ]; then 
    mkdir "$HOME/Videos"
fi

record() {
    local mode="$1"
    local dateTime
    dateTime=$(date +%Y-%m-%d-%H-%M-%S)

    if [ -f "$recording_flag" ]; then
        hyprlab notify -a Hyprlab Capture "Recording already in progress!" -i video
        hyprlab message fail "recording already in progress!"
        exit 0
    fi

    touch "$recording_flag"

    if [ "$mode" = "screen" ]; then
        region=$(slurp -o)
        [ -z "$region" ] && { rm -f "$recording_flag"; exit 0; }

        hyprlab notify -a Hyprlab Capture "Starting screen recording..." -i video
        hyprlab message ok "Starting screen recording..."
        wf-recorder --audio --bframes max_b_frames -g "$region" -f "$videoFolder/$dateTime.mp4"
    else
        region=$(slurp)
        [ -z "$region" ] && { rm -f "$recording_flag"; exit 0; } 
        hyprlab notify -a Hyprlab Capture "Starting region recording..." -i video
        hyprlab message ok "Starting region recording..."
        wf-recorder --audio --bframes max_b_frames -g "$region" -f "$videoFolder/$dateTime.mp4"
    fi

    rm -f "$recording_flag"
}

stopRecord() {
    if [[ -f $recording_flag ]]; then
        rm -f $recording_flag
        pkill -INT -x wf-recorder
        hyprlab notify -a Hyprlab Capture "Recording stopped\n$videoFolder" -i video
    else
        hyprlab message fail "Not recording"
    fi
}

help() {
  cat <<EOF
Usage : $(basename "$0") <commands>

Options :
  region      -> Select a region and start record
  screen      -> Select a screen and start record
  stop        -> Stop the actual record
  -h, --help  -> Show this message
EOF
}

case $1 in 
    screen | region) record $1;;
    stop) stopRecord;;
    "" | -h | --help) help && exit 0;;
    *) hyprlab message fail "Unknown command : $1" && exit 1;;
esac
    