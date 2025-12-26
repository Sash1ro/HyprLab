#!/usr/bin/env bash
set -euo pipefail

# Load configuration
source "$HOME/.config/hyprlab/scripts/data/conf.env"

CONFIG="$HOME/.config"
dossier="$THEMES_DIR/current"

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
NVIM="$CONFIG/nvim/lua/config/colorscheme.txt"
NCOLORS="$CONFIG/nvim/lua/utils/matugen.lua"
CAVA="$CONFIG/cava/themes/current"
FISH="$CONFIG/fish/themes/current.theme"

lien_conf() {
  local cible="$1" lien="$2" app="$3"
  ln -sfn "$lien" "$cible" \
   || (hyprlab message fail "Error while updating link for $app" && return 1)
  hyprlab message ok "Link updated for $app"
}

apply() {
  hyprlab message info "Updating configuration"
  lien_conf "$FISH" "$dossier/fish/theme.theme" "fish"
  lien_conf "$HYPR" "$dossier/hypr/colors.conf" "Hyprland"
  lien_conf "$WAYBAR" "$dossier/waybar/colors.css" "Waybar"
  lien_conf "$ROFI" "$dossier/rofi/colors.rasi" "Rofi"
  lien_conf "$CODIUM" "$dossier/vscode/settings.json" "VSCodium"
  lien_conf "$KITTY" "$dossier/kitty/colors.conf" "Kitty"
  lien_conf "$GTK3" "$dossier/gtk/gtk.css" "GTK3"
  lien_conf "$GTK4" "$dossier/gtk/gtk.css" "GTK4"
  lien_conf "$STARSHIP" "$dossier/starship/starship.toml" "Starship"
  lien_conf "$VESTOP" "$dossier/vesktop/current.theme.css" "Vesktop"
  lien_conf "$NVIM" "$dossier/nvim/colorscheme.txt" "Nvim"
  lien_conf "$CAVA" "$dossier/cava/theme" "cava"

  if [ -f "$dossier/nvim/colors.lua" ]; then
    lien_conf "$NCOLORS" "$dossier/nvim/colors.lua" "Nvim colors"
  fi
}

main() {
  apply || hyprlab message fail "Error while updating links"
}

main