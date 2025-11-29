#SCRIPT from jakoolit's hyprland dots

declare -A menu_options=(
  ["Lofi Girl ☕️🎶"]="https://play.streamafrica.net/lofiradio"
  ["Chillhop ☕️🎶"]="http://stream.zeno.fm/fyn8eh3h5f8uv"
  ["SmoothChill ☕️🎶"]="https://media-ssl.musicradio.com/SmoothChill"
  ["Minecraft Relax ☕️🎶"]="https://www.youtube.com/watch?v=yJ6Lbsmb1lY"
)

main() {
  choice=$(printf "%s\n" "${!menu_options[@]}" | rofi -i -dmenu -theme ~/.config/hyprlab/rofi/themes/list.rasi )

  if [ -z "$choice" ]; then
    exit 1
  fi

  link="${menu_options[$choice]}"

  hyprlab notify low "Hyprlab" "Media" "Playing now $choice"
  
  if [[ $link == *playlist* || $link == *watch* ]]; then
    mpv --shuffle --vid=no --volume=75 "$link"
  else
    mpv --volume=75 "$link"
  fi
}

pkill mpv && hyprlab notify low "Hyprlab" "Media" "Online Music stopped" || main