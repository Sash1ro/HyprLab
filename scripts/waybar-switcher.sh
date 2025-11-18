#!/usr/bin/env bash
#─────────────────────────────────────────────────────────────
#  🎨 Waybar Switcher
#─────────────────────────────────────────────────────────────
#  Hyprland, Waybar, Rofi, VSCode, Kitty, GTK, Starship, Fish, etc.
#  Gère aussi les tailles et le fond d’écran via swww.
#─────────────────────────────────────────────────────────────

set -euo pipefail

#─────────────────────────────────────────────────────────────
#  CHEMINS DE CONFIGURATION
#─────────────────────────────────────────────────────────────
CONFIG="$HOME/.config"
WAYBAR="$CONFIG/waybar"
THEMES="$CONFIG/hyprlab/waybar/themes"
CURRENT="$THEMES/current"

WAYBAR_CONF="$WAYBAR/config.jsonc"
WAYBAR_CSS="$WAYBAR/style.css"



#─────────────────────────────────────────────────────────────
#  ICONES + COULEURS
#─────────────────────────────────────────────────────────────
OK=""
FAIL="󰅙"
INFO=""

C_RESET="\e[0m"
C_GREEN="\e[32m"
C_RED="\e[31m"
C_BLUE="\e[34m"

#─────────────────────────────────────────────────────────────
#  OUTILS
#─────────────────────────────────────────────────────────────
msg_ok() { echo -e "${C_GREEN}${OK}${C_RESET} $*"; }
msg_fail() { echo -e "${C_RED}${FAIL}${C_RESET} $*"; }
msg_info() { echo -e "${C_BLUE}${INFO}${C_RESET} $*"; }

existe() { [[ -e "$1" ]]; }

lien_conf() {
  local cible="$1" lien="$2" app="$3"
  if existe "$cible" && [[ -n "$lien" && -e "$lien" ]]; then
    ln -sfn "$lien" "$cible"
    msg_ok "Lien mis à jour pour $app"
  else
    msg_fail "Fichiers manquants pour $app"
  fi
}

verif_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    msg_fail "Dépendance manquante : $1"
    exit 1
  }
}

#─────────────────────────────────────────────────────────────
#  APPLICATION DU THÈME
#─────────────────────────────────────────────────────────────
appliquer_theme() {
  local dossier="$1"

  if [[ ! -d "$dossier" ]]; then
    msg_fail "Ce thème n'existe pas : $(basename $dossier)"
    exit 1
  fi

  msg_info "Application du thème : $(basename "$dossier")"
  ln -sfn "$dossier" "$CURRENT"

  lien_conf  "$WAYBAR_CONF" "$dossier/config.jsonc" "Waybar conf"
  lien_conf  "$WAYBAR_CSS" "$dossier/style.css" "Waybar css"

  msg_info "Reloading Waybar ..."
  pkill waybar && hyprctl dispatch exec waybar
}


#─────────────────────────────────────────────────────────────
#  AIDE ET LISTE DES THEMES
#─────────────────────────────────────────────────────────────
aide() {
  cat <<EOF
Utilisation : $(basename "$0") [options]

Options :
  -t THEME       Appliquer un thème (nom du dossier dans $THEMES)
  -s TAILLE      Appliquer un profil de taille (1 ou 2)
  --liste        Afficher la liste des thèmes disponibles
  -h, --aide     Afficher ce message d’aide
EOF
}

liste_themes() {
  echo "🎨 Thèmes disponibles :"
  find "$THEMES" -mindepth 1 -maxdepth 1 -type d ! -name "current" ! -iname ".*" -exec basename {} \;
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

while [[ $# -gt 0 ]]; do
  case "$1" in
  -t)
    theme="$2"
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
    msg_fail "Option inconnue : $1"
    aide
    exit 1
    ;;
  esac
done

echo "$THEMES/$theme"
[[ "$theme" != "off" ]] && appliquer_theme "$THEMES/$theme"
