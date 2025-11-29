#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/hyprlab/scripts/data/conf.env"

CONFIG="$HOME/.config"
CURRENT="$THEMES_DIR/current"
SIZE_DIR="$THEMES_DIR/size"


GTK4="$CONFIG/gtk-4.0/gtk.css"
GTK3="$CONFIG/gtk-3.0/gtk.css"
CODIUM="$CONFIG/VSCodium/User/settings.json"
HYPR="$CONFIG/hyprlab/hyprland/conf/colors.conf"
RELOAD="$CONFIG/hyprlab/scripts/reload.sh"
WAYBAR="$CONFIG/waybar/colors.css"
KITTY="$CONFIG/kitty/colors.conf"
ROFI="$CONFIG/rofi/colors.rasi"
STARSHIP="$CONFIG/starship.toml"
VESTOP="$CONFIG/vesktop/themes/current.theme.css"
NVIM="$CONFIG/nvim/lua/plugins/colors.lua"
CAVA="$CONFIG/cava/themes/current"
FISH="$CONFIG/fish/themes/current.theme"


existe() { [[ -e "$1" ]]; }

lien_conf() {
  local cible="$1" lien="$2" app="$3"
  ln -sfn "$lien" "$cible"
  hyprlab message ok "Link updated for $app"
}

verif_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    hyprlab message fail "Missing dependencies : $1"
    exit 1
  }
}

set_couleur_fish() {

  if ! command -v fish >/dev/null; then
    hyprlab message fail "Fish is not installed"
    return
  fi

  lien_conf "$FISH" "$dossier/fish/theme.theme" "fish"
  printf "y\n" | fish -c "fish_config theme save current" >/dev/null 2>&1 
}

appliquer_icon() {
  local file="$1/folder"
  local icon=$(<"$file") 
  if command -v papirus-folders >/dev/null; then
    papirus-folders -C "$icon" 
  fi
}

appliquer_theme() {
  local dossier="$1"

  if [[ ! -d "$dossier" ]]; then
    hyprlab message fail "Unknown theme : $(basename $dossier)"
    exit 1
  fi

  hyprlab message info "Applying theme : $(basename "$dossier")"
  ln -sfn "$dossier" "$CURRENT"

  lien_conf "$HYPR" "$dossier/hypr/colors.conf" "Hyprland"
  lien_conf "$WAYBAR" "$dossier/waybar/colors.css" "Waybar"
  lien_conf "$ROFI" "$dossier/rofi/colors.rasi" "Rofi"
  lien_conf "$CODIUM" "$dossier/vscode/settings.json" "VSCodium"
  lien_conf "$KITTY" "$dossier/kitty/colors.conf" "Kitty"
  lien_conf "$GTK3" "$dossier/gtk/gtk.css" "GTK3"
  lien_conf "$GTK4" "$dossier/gtk/gtk.css" "GTK4"
  lien_conf "$STARSHIP" "$dossier/starship/starship.toml" "Starship"
  lien_conf "$VESTOP" "$dossier/vesktop/current.theme.css" "Vesktop"
  lien_conf "$NVIM" "$dossier/nvim/colors.lua" "Nvim"
  lien_conf "$CAVA" "$dossier/cava/theme" "cava"

  set_couleur_fish 

  hyprlab message ok "Changing wallpaper..."
  verif_cmd swww

  first_file=$(echo "$dossier"/wallpapers/default.* | awk '{print $1}')
  if [[ ! -f "$dossier/wallpaper"  ]];then 
     hyprlab wallpaper set "$first_file"
  else
    swww img "$dossier/wallpaper" --transition-type grow --transition-fps 60 || hyprlab message fail "Error while changing wallpaper"
  fi

  hyprlab message info "Restart gtk apps to see changes"
  
  hyprlab message info "Applying Papirus icon theme"
  appliquer_icon "$dossier"
}


changer_police_gtk() {
  local police="$1"
  gsettings set org.gnome.desktop.interface font-name "$police"
}

appliquer_taille() {
  local s="$1"
  hyprlab message info "Applying size profile : $s"
  case "$s" in
  1)
    lien_conf "$CONFIG/kitty/size.conf" "$SIZE_DIR/size.conf" "Taille Kitty"
    lien_conf "$CONFIG/waybar/size.css" "$SIZE_DIR/size.css" "Taille Waybar"
    lien_conf "$CONFIG/rofi/size.rasi" "$SIZE_DIR/size.rasi" "Taille Rofi"
    changer_police_gtk 'SF Pro Display Bold 10' || hyprlab message fail "Error while applying gtk font"
    
    ;;
  2)
    lien_conf "$CONFIG/kitty/size.conf" "$SIZE_DIR/size2k.conf" "Taille Kitty (2K)"
    lien_conf "$CONFIG/waybar/size.css" "$SIZE_DIR/size2k.css" "Taille Waybar (2K)"
    lien_conf "$CONFIG/rofi/size.rasi" "$SIZE_DIR/size2k.rasi" "Taille Rofi (2K)"
    changer_police_gtk 'SF Pro Display Bold 13' || hyprlab message fail "Error while applying gtk font"
    
    ;;
  *)
    hyprlab message fail "Unknown profile size : $s"
    ;;
  esac
}

help() {
  cat <<EOF
Usage : $(basename "$0") [options]

Options :
  -t          -> Apply a theme 
  -s          -> Apply a size profile (1 (1920x1080) or 2 (2560x1440))
  --selected  -> Show the selected theme
  --list      -> Show themes list
  -h, --help  -> Show this message
EOF
}

list_themes() {
  echo "🎨 Themes :"
  find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d ! -name "size" ! -name "current" ! -iname ".*" -exec basename {} \;
}

selected_theme() {
  selectedTheme=$(readlink -f $CURRENT)
  themeName=$(basename "$selectedTheme")

  echo $themeName
}

#─────────────────────────────────────────────────────────────
#  MAIN
#─────────────────────────────────────────────────────────────
theme="off"
taille="off"

while [[ $# -gt 0 ]]; do
  case "$1" in
  -t)
    theme="$2"
    shift 2
    ;;
  -s)
    taille="$2"
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
    hyprlab message fail "Unknown option : $1"
    help
    exit 1
    ;;
  esac
done

[[ "$theme" != "off" ]] && appliquer_theme "$THEMES_DIR/$theme" && hyprlab notify normal "Hyprlab" "Updated theme" "Actual : $theme" -i "hypr"
[[ "$taille" != "off" ]] && appliquer_taille "$taille" && hyprlab notify normal "Hyprlab" "Updated size profile" "Actual : $taille" -i "hypr"
hyprlab reload
