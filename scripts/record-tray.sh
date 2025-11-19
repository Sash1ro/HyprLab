#!/usr/bin/env bash

source $HOME/.config/hyprlab/scripts/data/conf.env

recording_flag="$SCRIPT_DIR/cache/wf-recorder-active"

if [[ -f $recording_flag ]]; then
     echo -e '<span color="#f38ba8"></span>'
fi