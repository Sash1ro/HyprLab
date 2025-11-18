#!/usr/bin/env sh

#Hyprland
echo " Rechargement commencé..."
echo "󰑓 Hyprland"
hyprctl reload >/dev/null && echo "OK" || echo "Erreur"

#nautilus

if pgrep -x "nautilus" >/dev/null; then
    echo "󰑓 Nautilus"
    nautilus -q >/dev/null && echo "OK" || echo "Erreur"
fi

#gtk
echo "󰑓 GTK"
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-gtk && echo "OK" || echo "Erreur"

#WAYBAR
if pgrep -x "waybar" >/dev/null; then
    echo "󰑓 Waybar"
    pkill waybar
    hyprctl dispatch exec waybar >/dev/null && echo "OK" || echo "Erreur"
fi

#SWAYNC
if pgrep -x "swaync" >/dev/null; then
    echo "󰑓 Swaync"
    swaync-client -R -rs >/dev/null && echo "OK" || echo "Erreur"
fi