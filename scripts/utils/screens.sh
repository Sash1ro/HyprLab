#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"

last=""
if [ -n $(printenv "$PRIMARY") ]; then
    last=$PRIMARY
fi

json=$(hyprctl -j monitors all)

number=$(jq '. | length' <<< "$json")

mapfile -t NAMES < <(jq -r '.[].name' <<< "$json")
mapfile -t WIDTH < <(jq -r '.[].width' <<< "$json")
mapfile -t HEIGHT < <(jq -r '.[].height' <<< "$json")
mapfile -t POSITIONS < <(jq -r '.[] | "\(.x)x\(.y)"' <<< "$json")
mapfile -t HZ < <(jq -r '
  .[] |
  (.availableModes
    | map(capture("@(?<hz>[0-9.]+)Hz").hz | tonumber)
    | max
  )
' <<< "$json")


PRIMARY=$(jq -r '
  max_by(
    (.width * .height) * 100000 +
    (.availableModes | map(capture("@(?<hz>[0-9.]+)Hz").hz | tonumber) | max)
  ) | .name
' <<< "$json")


if [ "$number" -gt 1 ]; then
  SECONDARY=$(jq -r '
    sort_by(
      -(
        (.width * .height) * 100000 +
        (.availableModes | map(capture("@(?<hz>[0-9.]+)Hz").hz | tonumber) | max)
      )
    )[1].name
  ' <<< "$json")
fi


arg=${1:-}

if [ -n "$arg" ] && [ "$arg" == "detect" ]; then
  echo $last
  echo $PRIMARY
  if [ ! "$PRIMARY" == "$last" ]; then
    hyprlab notify normal "Hyprlab" "Monitors" "Another primary monitor detected" 
  fi
  exit 0
fi

file="$HYPRLAB/hyprland/monitors_profile/current"
[ -n "$arg" ] && [ -f "$arg" ] && file=$arg

: > "$file"


for i in "${!NAMES[@]}"; do
  echo "monitor=${NAMES[$i]},${WIDTH[$i]}x${HEIGHT[$i]}@${HZ[$i]},${POSITIONS[$i]},auto" >> "$file"
done


echo "\$PRIMARY=$PRIMARY" >> "$file"
echo "env=PRIMARY,$PRIMARY" >> "$file"

if [ ! -z ${SECONDARY:-} ]; then 
  echo "\$SECOND=$SECONDARY" >> "$file"
  echo "env=SECONDARY,$SECONDARY" >> "$file"
fi
