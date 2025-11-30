# # Source system config
source /usr/share/cachyos-fish-config/cachyos-config.fish

# Android SDK
set -x ANDROID_SDK_ROOT $HOME/Android/Sdk
set -x ANDROID_HOME $ANDROID_SDK_ROOT

fish_add_path ~/.local/bin

fastfetch
starship init fish | source
