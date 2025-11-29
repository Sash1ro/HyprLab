#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"
export PATH="$SCRIPT_DIR/bin:$PATH"

CONFIG="$HOME/.config"
WAYBAR="$CONFIG/waybar"
THEMES="$CONFIG/hyprlab/waybar/themes"
CURRENT="$THEMES/current"

WAYBAR_CONF="$WAYBAR/config.jsonc"
WAYBAR_CSS="$WAYBAR/style.css"

existe() { [[ -e "$1" ]]; }

link_conf() {
  local cible="$1" lien="$2" app="$3"
  ln -sfn "$lien" "$cible"
  hyprlab message ok "Updated link for $app"
}

verif_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    hyprlab message fail "Missing dependancies : $1"
    exit 1
  }
}

apply_theme() {
  local dossier="$1"

  if [[ ! -d "$dossier" ]]; then
    hyprlab message fail "Unknown theme : $(basename $dossier)"
    exit 1
  fi

  hyprlab message info "Applying theme : $(basename "$dossier")"
  ln -sfn "$dossier" "$CURRENT"

  link_conf  "$WAYBAR_CONF" "$dossier/config.jsonc" "Waybar conf"
  link_conf  "$WAYBAR_CSS" "$dossier/style.css" "Waybar css"

  hyprlab message info "Reloading Waybar ..."
  pkill waybar && hyprctl dispatch exec waybar
}

help() {
  cat <<EOF
Usage : $(basename "$0") [options]

Options :
  -t          -> Apply a theme 
  --selected  -> Show the selected theme
  --list      -> Show themes list
  -h, --help  -> Show this message
EOF
}

list_themes() {
  echo "🎨 Waybar themes :"
  find "$THEMES" -mindepth 1 -maxdepth 1 -type d ! -name "current" ! -iname ".*" -exec basename {} \;
}

selected_theme() {
  selectedTheme=$(readlink -f $CURRENT)
  themeName=$(basename "$selectedTheme")

  echo $themeName
}

theme="off"

while [[ $# -gt 0 ]]; do
  case "$1" in
  -t)
    theme="$2"
    shift 2
    ;;
  --list)
    list_themes
    exit 0
    ;;
  --selected)
    selected_theme
    exit 0
    ;;
  -h | --help | "")
    help
    exit 0
    ;;
  *)
    hyprlab message fail "Unknown options : $1"
    help
    exit 1
    ;;
  esac
done

[[ "$theme" != "off" ]] && apply_theme "$THEMES/$theme" && hyprlab notify normal "Hyprlab" "Updated waybar" "Actual : $theme" -i "hypr"