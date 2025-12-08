#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"
file="$HYPRLAB/themes/current/folder"
distpy="$HYPRLAB/scripts/py/dist.py"
declare -A COLORS=(
    ["cyan"]="#00BCD4"
    ["green"]="#87B158"
    ["red"]="#16a085"
    ["blue"]="#57B8EC"
    ["pink"]="#F06292"
    ["indigo"]="#5C6BC0"
    ["yellow"]="#F9BD30"
    ["magenta"]="#CA71DF"
    ["orange"]="#EE923A"
    ["teal"]="#16A085"
    ["carmine"]="#A30002"
    ["violet"]="#7E57C2"
    ["deeporange"]="#EB6637"
)

dist() {
    local a=$1 b=$2
    python3 "$distpy" "$a" "$b"
}

base="$(<$file)"  

first=${COLORS["cyan"]}
min=$(dist "$base" "$first")
result="cyan"

for name in "${!COLORS[@]}"; do
    DIST=$(dist "$base" "${COLORS[$name]}")
    if awk -v d="$DIST" -v m="$min" 'BEGIN {exit !(d < m)}'; then
        min=$DIST
        result="$name"
    fi
done


appliquer_icon() { 
  if command -v papirus-folders >/dev/null; then
    papirus-folders -C "$result" 
  fi
}

appliquer_icon
echo "La couleur la plus proche de $base est : $result"
