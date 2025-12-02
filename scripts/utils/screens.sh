#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"

mapfile -t NAMES < <(hyprctl -j monitors all | jq -r '.[].name')
mapfile -t WIDTH < <(hyprctl -j monitors all | jq -r '.[].width')
mapfile -t HEIGHT < <(hyprctl -j monitors all | jq -r '.[].height')
mapfile -t POSITIONS < <(hyprctl -j monitors | jq -r '.[] | "\(.x)x\(.y)"')

mapfile -t HZ < <(hyprctl -j monitors all | jq -r '
  .[] |
  (.availableModes
    | map(capture("@(?<hz>[0-9.]+)Hz").hz | tonumber)
    | max
  )
')

PRIMARY=$(hyprctl -j monitors all | jq -r '
  max_by(
    (.width * .height) * 100000 +
    (.availableModes | map(capture("@(?<hz>[0-9.]+)Hz").hz | tonumber) | max)
  ) | .name
')

file="$HYPRLAB/hyprland/conf/monitors.conf"
lines=""
# Example usage
for i in "${!NAMES[@]}"; do
  lines+="monitor=${NAMES[$i]},${WIDTH[$i]}x${HEIGHT[$i]}@${HZ[$i]},${POSITIONS[$i]},auto"
done

printf "%s\n" "${lines[@]}" > "$file"
echo "\$PRIMARY=$PRIMARY" >> "$file"
echo "\$ENV=PRIMARY,\$PRIMARY" >> "$file"

