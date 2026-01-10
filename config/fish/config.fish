# # Source system config
source /usr/share/cachyos-fish-config/cachyos-config.fish

# Android SDK
set -x ANDROID_SDK_ROOT $HOME/Android/Sdk
set -x ANDROID_HOME $ANDROID_SDK_ROOT
set -x CAPACITOR_ANDROID_STUDIO_PATH /opt/android-studio/bin/studio.sh
set -x EDITOR nvim

set -x JAVA_HOME /usr/lib/jvm/java-21-openjdk
fish_add_path $JAVA_HOME/bin
fish_add_path ~/.local/bin

fastfetch
starship init fish | source
