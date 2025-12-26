#!/usr/bin/env bash

source "$HOME/.config/hyprlab/scripts/data/conf.env"

#Hyprland
hyprlab message info "Reloading services..."
hyprlab message info "Reloading Hyprland"
hyprctl reload >/dev/null && hyprlab message ok "Hyprland reloaded" || hyprlab message fail "Error while reloading Hyprland"

touch "$HOME/.config/hypr/hyprlock.conf"

if pgrep -x cava >/dev/null; then
    hyprlab message info "Reloading Cava"
    pkill -USR1 cava 2>/dev/null || pkill cava
fi

#gtk
hyprlab message info "Reloading GTK"
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-gtk && hyprlab message ok "GTK reloaded" || hyprlab message fail "Error while reloading GTK"
hyprlab message info "For gtk4 apps, restart them to see any changes !"

#WAYBAR
if pgrep -x "waybar" >/dev/null; then
    hyprlab message info "Reloading Waybar"
    pkill waybar
    hyprctl -q dispatch exec waybar && hyprlab message ok "Waybar reloaded" || hyprlab message fail "Error while reloading Waybar"
fi

if pgrep -x "nautilus" >/dev/null; then
    hyprlab message info "Reloading nautilus, closing all window"
    nautilus -q && hyprlab message ok "Nautilus reloaded" || hyprlab message fail "Error while reloading Nautilus"
fi

#SWAYNC
if pgrep -x "swaync" >/dev/null; then
    "$SCRIPT_DIR/utils/update-swaync.sh"
fi

#Kitty
hyprlab message info "Reloading Kitty"
kill -SIGUSR1 $(pidof kitty) >/dev/null && hyprlab message ok "Kitty reloaded" || hyprlab message error "Error while reloading Kitty"