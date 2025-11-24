#!/usr/bin/env bash
set -euo pipefail

source $HOME/.config/hyprlab/scripts/data/conf.env

defaultConfig() {
    cp -a "$HYPRLAB/dots/hypr/." "$HOME/.config/hypr/"
    cp -a "$HYPRLAB/dots/kitty/." "$HOME/.config/kitty/"
    cp -a "$HYPRLAB/dots/gtk-3.0/." "$HOME/.config/gtk-3.0/"
    cp -a "$HYPRLAB/dots/gtk-4.0/." "$HOME/.config/gtk-4.0/"
    cp -a "$HYPRLAB/dots/nvim/." "$HOME/.config/nvim/"
    cp -a "$HYPRLAB/dots/rofi/." "$HOME/.config/rofi/"
    cp -a "$HYPRLAB/dots/cava/." "$HOME/.config/cava/"
    cp -a "$HYPRLAB/dots/btop/." "$HOME/.config/btop/"
    cp -a "$HYPRLAB/dots/swaync/." "$HOME/.config/swaync/"
    cp -a "$HYPRLAB/dots/wlogout/." "$HOME/.config/wlogout/"
}

setupCodium() {
    if ! command -v codium >/dev/null; then
        echo "Codium is not installed"
        return
    fi

    #Icon theme
    codium --install-extension PKief.material-icon-theme 
    codium --install-extension PKief.material-product-icons

    #Themes
    codium --install-extension Catppuccin.catppuccin-vsc
    codium --install-extension mvllow.rose-pine
    codium --install-extension sainnhe.everforest
    codium --install-extension arcticicestudio.nord-visual-studio-code
    codium --install-extension enkia.tokyo-night

    #extentions
    codium --install-extension esbenp.prettier-vscode

    if [[ -f "$HOME/.config/VSCodium/User/settings.json" ]]; then
        rm "$HOME/.config/VSCodium/User/settings.json"
        touch "$HOME/.config/VSCodium/User/settings.json"
    fi
}

if [[ -d "$HYPRLAB/themes/current" ]]; then
    rm "$HYPRLAB/themes/current"
fi

#Default files for symlinks
touch "$HOME/.config/gtk-3.0/gtk.css"
touch "$HOME/.config/gtk-4.0/gtk.css"

touch "$HOME/.config/rofi/size.rasi"
touch "$HOME/.config/kitty/size.conf"
touch "$HOME/.config/waybar/size.css"

touch "$HOME/.config/rofi/colors.css"

mkdir -p "$HOME/.config/cava/themes"
mkdir -p "$HOME/.config/fish/themes"

touch "$HOME/.config/cava/themes/current"
touch "$HOME/.config/fish/themes/current.theme"
touch "$HOME/.config/waybar/config.jsonc"
touch "$HOME/.config/waybar/style.css"

touch "$HOME/.config/vesktop/themes/current.theme.css"

if [[ -f "$HYPRLAB/hyprland/conf/colors.conf" ]]; then
    rm "$HYPRLAB/hyprland/conf/colors.conf"
    touch "$HYPRLAB/hyprland/conf/colors.conf"
fi

if [[ -f "$HOME/.config/starship.toml" ]]; then 
    rm "$HOME/.config/starship.toml"
    touch $HOME/.config/starship.toml
fi

for d in "$HYPRLAB"/themes/*; do
    if [[ -f "$d/wallpaper" ]]; then
        rm "$d/wallpaper"
    fi
done


#Tokyo Night by default
$SCRIPT_DIR/themes-switcher.sh -t "tokyo-night" || echo "Error while applying default theme"
swww-daemon & waybar & swaync

