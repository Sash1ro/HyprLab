#!/usr/bin/env bash
#─────────────────────────────────────────────────────────────
#  🎨 Gestionnaire de thèmes Hyprland
#─────────────────────────────────────────────────────────────
#  Hyprland, Waybar, Rofi, VSCode, Kitty, GTK, Starship, Fish, etc.
#  Gère aussi les tailles et le fond d’écran via swww.
#─────────────────────────────────────────────────────────────

set -euo pipefail

#─────────────────────────────────────────────────────────────
#  CHEMINS DE CONFIGURATION
#─────────────────────────────────────────────────────────────
CONFIG="$HOME/.config"
THEMES="$CONFIG/hyprlab/themes"
CURRENT="$THEMES/current"
SIZE_DIR="$THEMES/size"
WALLPAPER_DIR="$HOME/Images/Wallpapers"

# Applications cibles
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

FIREFOX_PROFILE=$(ls "$HOME/.mozilla/firefox" | grep '\.default-release-' | head -n1 || true)
FIREFOX="$HOME/.mozilla/firefox/$FIREFOX_PROFILE/chrome/colors.css"

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
#  COULEURS FISH
#─────────────────────────────────────────────────────────────
set_couleur_fish() {
  local themeName="$1"
  if ! command -v fish >/dev/null; then
    msg_fail "Fish n'est pas installé."
    return
  fi

  local themeList
  themeList=$(fish -c "fish_config theme list" 2>/dev/null || true)
  themeName=$(echo "$themeName" | tr '[:upper:]' '[:lower:]' | tr '_-' ' ')
  local match
  match=$(echo "$themeList" | grep -i "$themeName" || true)

  if [[ -n "$match" ]]; then
    msg_ok "Thème Fish trouvé : $match"
    printf "y\n" | fish -c "fish_config theme save \"$match\"" >/dev/null 2>&1
  else
    msg_fail "Aucun thème Fish correspondant à '$themeName'"
  fi
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

  local fishColor
  fishColor=$(cat "$dossier/fish" 2>/dev/null || true)

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

  set_couleur_fish "$fishColor"

  msg_ok "Changement du fond d’écran..."
  verif_cmd swww
  swww img "$dossier/wallpaper" --transition-type grow --transition-fps 60 || msg_fail "Erreur lors du changement du fond d’écran"

  msg_info "Relancez Firefox, les apps GTK et kitty pour voir les changements"
  [[ -x "$RELOAD" ]] && "$RELOAD"
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
  msg_info "Application du profil de taille : $s"
  case "$s" in
  1)
    lien_conf "$CONFIG/kitty/size.conf" "$SIZE_DIR/size.conf" "Taille Kitty"
    lien_conf "$CONFIG/waybar/size.css" "$SIZE_DIR/size.css" "Taille Waybar"
    lien_conf "$CONFIG/rofi/size.rasi" "$SIZE_DIR/size.rasi" "Taille Rofi"
    changer_police_gtk 'SF Pro Display Bold 10' || msg_fail "Erreur lors du changement de la police GTK"
    [[ -x "$RELOAD" ]] && "$RELOAD"
    ;;
  2)
    lien_conf "$CONFIG/kitty/size.conf" "$SIZE_DIR/size2k.conf" "Taille Kitty (2K)"
    lien_conf "$CONFIG/waybar/size.css" "$SIZE_DIR/size2k.css" "Taille Waybar (2K)"
    lien_conf "$CONFIG/rofi/size.rasi" "$SIZE_DIR/size2k.rasi" "Taille Rofi (2K)"
    changer_police_gtk 'SF Pro Display Bold 13' || msg_fail "Erreur lors du changement de la police GTK"
    [[ -x "$RELOAD" ]] && "$RELOAD"
    ;;
  *)
    msg_fail "Profil de taille inconnu : $s"
    ;;
  esac
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
  find "$THEMES" -mindepth 1 -maxdepth 1 -type d ! -name "size" ! -name "current" ! -iname ".*" -exec basename {} \;
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
    msg_fail "Option inconnue : $1"
    aide
    exit 1
    ;;
  esac
done

[[ "$theme" != "off" ]] && appliquer_theme "$THEMES/$theme"
[[ "$taille" != "off" ]] && appliquer_taille "$taille"
