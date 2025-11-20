#!/usr/bin/env bash
set -euo pipefail

source $HOME/.config/hyprlab/scripts/data/conf.env

CONFIG="$HOME/.config"
CURRENT="$THEMES_DIR/current"
SIZE_DIR="$THEMES_DIR/size"


GTK4="$CONFIG/gtk-4.0/gtk.css"
GTK3="$CONFIG/gtk-3.0/gtk.css"
CODIUM="$CONFIG/VSCodium/User/settings.json"
CODE="$CONFIG/Code/User/settings.json"
HYPR="$CONFIG/hyprlab/hyprland/conf/colors.conf"
RELOAD="$CONFIG/hyprlab/scripts/reload.sh"
WAYBAR="$CONFIG/waybar/colors.css"
KITTY="$CONFIG/kitty/colors.conf"
ROFI="$CONFIG/rofi/colors.rasi"
STARSHIP="$CONFIG/starship.toml"
VESTOP="$CONFIG/vesktop/themes/current.theme.css"
NVIM="$CONFIG/nvim/lua/plugins/colors.lua"
BTOP="$CONFIG/btop/themes/current.theme"
CAVA="$CONFIG/cava/themes/current"
FISH="$CONFIG/fish/themes/current.theme"

FIREFOX_PROFILE=$(ls "$HOME/.mozilla/firefox" | grep '\.default-release-' | head -n1 || true)
FIREFOX="$HOME/.mozilla/firefox/$FIREFOX_PROFILE/chrome/colors.css"

OK=""
FAIL="󰅙"
INFO=""

C_RESET="\e[0m"
C_GREEN="\e[32m"
C_RED="\e[31m"
C_BLUE="\e[34m"

msg_ok() { echo -e "${C_GREEN}${OK}${C_RESET} $*"; }
msg_fail() { echo -e "${C_RED}${FAIL}${C_RESET} $*"; }
msg_info() { echo -e "${C_BLUE}${INFO}${C_RESET} $*"; }

existe() { [[ -e "$1" ]]; }

lien_conf() {
  local cible="$1" lien="$2" app="$3"
  if existe "$cible" && [[ -n "$lien" && -e "$lien" ]]; then
    ln -sfn "$lien" "$cible"
    msg_ok "Link updated for $app"
  else
    msg_fail "Missing files for $app"
  fi
}

verif_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    msg_fail "Missing dependencies : $1"
    exit 1
  }
}

set_couleur_fish() {

  if ! command -v fish >/dev/null; then
    msg_fail "Fish is not installed"
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
    msg_fail "Unknown theme : $(basename $dossier)"
    exit 1
  fi

  msg_info "Applying theme : $(basename "$dossier")"
  ln -sfn "$dossier" "$CURRENT"

  lien_conf "$HYPR" "$dossier/hypr/colors.conf" "Hyprland"
  lien_conf "$WAYBAR" "$dossier/waybar/colors.css" "Waybar"
  lien_conf "$ROFI" "$dossier/rofi/colors.rasi" "Rofi"
  lien_conf "$CODIUM" "$dossier/vscode/settings.json" "VSCodium"
  lien_conf "$CODE" "$dossier/vscode/settings.json" "VSCode"
  lien_conf "$KITTY" "$dossier/kitty/colors.conf" "Kitty"
  lien_conf "$FIREFOX" "$dossier/firefox/colors.css" "Firefox"
  lien_conf "$GTK3" "$dossier/gtk/gtk.css" "GTK3"
  lien_conf "$GTK4" "$dossier/gtk/gtk.css" "GTK4"
  lien_conf "$STARSHIP" "$dossier/starship/starship.toml" "Starship"
  lien_conf "$VESTOP" "$dossier/vesktop/current.theme.css" "Vesktop"
  lien_conf "$NVIM" "$dossier/nvim/colors.lua" "Nvim"
  lien_conf "$BTOP" "$dossier/btop/theme.theme" "btop"
  lien_conf "$CAVA" "$dossier/cava/theme" "cava"

  set_couleur_fish 

  msg_ok "Changing wallpaper..."
  verif_cmd swww
  swww img "$dossier/wallpaper" --transition-type grow --transition-fps 60 || msg_fail "Error while changing wallpaper"

  msg_info "Restart firefox, gtk apps to see changes"
  [[ -x "$RELOAD" ]] && "$RELOAD"

   msg_info "Applying Papirus icon theme"
   appliquer_icon "$dossier"
}

#─────────────────────────────────────────────────────────────
#  GESTION DES TAILLES
#─────────────────────────────────────────────────────────────
changer_police_gtk() {
  local police="$1"
  gsettings set org.gnome.desktop.interface font-name "$police"
}

appliquer_taille() {
  local s="$1"
  msg_info "Applying size profile : $s"
  case "$s" in
  1)
    lien_conf "$CONFIG/kitty/size.conf" "$SIZE_DIR/size.conf" "Taille Kitty"
    lien_conf "$CONFIG/waybar/size.css" "$SIZE_DIR/size.css" "Taille Waybar"
    lien_conf "$CONFIG/rofi/size.rasi" "$SIZE_DIR/size.rasi" "Taille Rofi"
    changer_police_gtk 'SF Pro Display Bold 10' || msg_fail "Error while applying gtk font"
    [[ -x "$RELOAD" ]] && "$RELOAD"
    ;;
  2)
    lien_conf "$CONFIG/kitty/size.conf" "$SIZE_DIR/size2k.conf" "Taille Kitty (2K)"
    lien_conf "$CONFIG/waybar/size.css" "$SIZE_DIR/size2k.css" "Taille Waybar (2K)"
    lien_conf "$CONFIG/rofi/size.rasi" "$SIZE_DIR/size2k.rasi" "Taille Rofi (2K)"
    changer_police_gtk 'SF Pro Display Bold 13' || msg_fail "Error while applying gtk font"
    [[ -x "$RELOAD" ]] && "$RELOAD"
    ;;
  *)
    msg_fail "Unknown profile size : $s"
    ;;
  esac
}

#─────────────────────────────────────────────────────────────
#  AIDE ET LISTE DES THEMES
#─────────────────────────────────────────────────────────────
aide() {
  cat <<EOF
Usage : $(basename "$0") [options]

Options :
  -t THEME       Apply a theme 
  -s TAILLE      Apply a size profile (1 (1920x1080) ou 2 (2560x1440))
  --liste        Show themes list
  -h, --aide     Show this message
EOF
}

liste_themes() {
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
  --liste)
    liste_themes
    exit 0
    ;;
  --selected)
    selected_theme
    exit 0
    ;;
  -h | --aide)
    aide
    exit 0
    ;;
  *)
    msg_fail "Unknown option : $1"
    aide
    exit 1
    ;;
  esac
done

[[ "$theme" != "off" ]] && appliquer_theme "$THEMES_DIR/$theme"
[[ "$taille" != "off" ]] && appliquer_taille "$taille"
