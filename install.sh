#!/usr/bin/env bash

set -euo pipefail

clear

pkgs=(
  "nautilus"
  "adw-gtk-theme"
  "vesktop"
  "vscodium"
  "waybar"
  "nvim"
  "cava"
  "btop"
  "rofi"
  "hyprshot"
  "hyprlock"
  "swww"
  "swaync"
  "wlogout"
  "wf-recorder"
  "slurp"
  "ttf-jetbrains-mono-nerd"
  "papirus-folders-git"
  "starship"
  "zenity"
  "eza"
  "fish"
  "wl-clipboard"
  "cliphist"
  "base-devel"
  "git"
  "wget"
  "nvibrant"
  "pavucontrol"
  "blueman-manager"
  "NetworkManager-git"
  "mpris"
  "yt-dlp"
  "mpv-mpris"
  "mpv"
  "playerctl"
  "hyprsunset"
)

OK="☑"
FAIL="☒"
INFO="->"

C_RESET="\e[0m"
C_GREEN="\e[32m"
C_RED="\e[31m"
C_BLUE="\e[34m"

msg_ok() { echo -e "${C_GREEN}${OK}${C_RESET} $*"; }
msg_fail() { echo -e "${C_RED}${FAIL}${C_RESET} $*"; }
msg_info() { echo -e "${C_BLUE}${INFO}${C_RESET} $*"; }

TERMINAL="${TERMINAL:-kitty}"
gitURL="https://github.com/Sash1ro/HyprLab.git"
CONFIG="$HOME/.config"
HYPRLAB="$CONFIG/hyprlab"
BACKUP_DIR="$HOME/conf-backups"

if ! command -v pacman >/dev/null; then
  msg_fail "This setup is only compatible (for now) with Arch Linux based distros"
  exit 1
fi

if ! pacman -Qi hyprland >/dev/null 2>&1; then
  msg_fail "Please install hyprland first!"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

if [[ ! -d "$CONFIG" ]]; then
  msg_fail "No config folder found in: $CONFIG"
  exit 1
fi

# --- Ask for sudo once and keep it alive ---
if [[ $EUID -ne 0 ]]; then
  msg_info "Requesting sudo access..."
  sudo -v || (msg_fail "sudo access is required" && exit 1)

  # Keep-alive: update existing sudo timestamp until script finishes
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
fi

backup() {
  dirs=("hypr" "fish" "fastfetch" "kitty" "swaync" "waybar" "wlogout" "rofi" "nvim" "cava" "gtk-3.0" "gtk-4.0" "btop")
  files=("starship.toml")

  msg_info "Backing up your configs"

  for d in "${dirs[@]}"; do
    if [[ -d "$CONFIG/$d" ]]; then
      mv "$CONFIG/$d" "$BACKUP_DIR/$d.bak"
      mkdir -p "$CONFIG/$d"
    fi
  done

  for f in "${files[@]}"; do
    if [[ -f "$CONFIG/$f" ]]; then
      mv "$CONFIG/$f" "$BACKUP_DIR/$f.bak"
    fi
  done

  msg_ok "Backup complete"
}

# --- Yay install ---
yayInstall() {
  msg_info "Cloning yay..."
  cd /tmp || exit
  git clone "https://aur.archlinux.org/yay.git"
  cd "yay" || exit

  msg_info "Installing yay..."
  makepkg -si --noconfirm

  cd ..
  rm -rf "yay"
  msg_ok "Yay install complete"
}

# --- Package installation ---
installPkgs() {
  if ! command -v yay >/dev/null 2>&1; then
    yayInstall || (msg_fail "Error while installing yay" && exit 1)
  fi

  # Papirus icon theme
  if [[ ! -d "$HOME/.local/share/icons/Papirus" ]]; then
    msg_info "Installing Papirus icon theme"
    wget -qO- "https://git.io/papirus-icon-theme-install" |
      env DESTDIR="$HOME/.local/share/icons" sh
  fi

  msg_info "Updating package database"
  yay -Sy --noconfirm

  for pkg in "${pkgs[@]}"; do
    msg_info "Checking: $pkg"
    if ! yay -Qi "$pkg" >/dev/null 2>&1; then
      msg_info "Installing $pkg"
      yay -S --noconfirm --needed "$pkg" &&
        msg_ok "$pkg installed" ||
        (msg_fail "Failed to install $pkg" && exit 1)
    else
      msg_info "$pkg is already installed"
    fi
  done

  msg_ok "All required packages installed"
}

# --- Fish setup ---
setupFish() {
  local fishConfig="$CONFIG/fish/config.fish"
  msg_info "Setting up fish"
  mkdir -p "$(dirname "$fishConfig")"

  if ! command -v fish >/dev/null 2>&1; then
    msg_fail "Fish is not installed"
    return 1
  fi

  [[ ! -f "$fishConfig" ]] && touch "$fishConfig"

  local fishPath
  fishPath=$(command -v fish)

  if ! grep -q "$fishPath" /etc/shells; then
    msg_info "Adding $fishPath in /etc/shells"
    echo "$fishPath" | sudo tee -a /etc/shells >/dev/null
  fi

  msg_info "Changing default shell to fish. You may need to log out and log in."
  chsh -s "$fishPath"

  msg_ok "Fish setup complete"
}

# --- Clone HyprLab ---
hyprlabClone() {
  if [[ ! -d "$HYPRLAB" ]]; then
    msg_info "Cloning HyprLab repo"
    git clone "$gitURL" "$HYPRLAB"
  else
    msg_info "HyprLab already cloned"
  fi
  msg_ok "HyprLab download complete"

  if ! zenity --question --title="HyprLab" --text="Do you have an AZERTY keyboard ?" --width=250; then
    sed -i "s/^[[:space:]]*kb_layout[[:space:]]*=.*/kb_layout = en/" "$HYPRLAB/hyprland/conf/input.conf"
  fi
}

# --- Font setup ---
FONT_DIR="$HYPRLAB/fonts/SF-Pro"
SYSTEM_FONT_DIR="/usr/local/share/fonts/otf"

fontSetup() {
  msg_info "Copying fonts to system fonts"
  sudo mkdir -p "$SYSTEM_FONT_DIR/sf-pro"
  sudo cp "$FONT_DIR"/*.otf "$SYSTEM_FONT_DIR/sf-pro"
  fc-cache -fv
  msg_ok "Font setup complete"
}

# --- Icons ---
iconApply() {
  if command -v papirus-folders >/dev/null; then
    msg_info "Applying Papirus icons"
    papirus-folders -C blue
    msg_ok "Icon setup complete"
  fi
}

# --- GPU detection ---
setupGpu() {
  msg_info "GPU detection..."
  if lspci | grep -i nvidia >/dev/null; then
    msg_info "Found NVIDIA GPU"
    grep -qxF "source=~/.config/hyprlab/hyprland/conf/nvidia.conf" "$HOME/.config/hyprlab/hyprland/conf/env.conf" ||
      printf "%s\n" "source=~/.config/hyprlab/hyprland/conf/nvidia.conf" >>"$HOME/.config/hyprlab/hyprland/conf/env.conf"
  else
    msg_info "Found compatible GPU"
  fi
  msg_ok "GPU detection complete"
}

# --- Applications ---
setupApplications() {
  msg_info "Copying .desktop files"
  local apps="$HYPRLAB/applications"
  for app in "$apps"/*; do
    cp -a "$app" "$HOME/.local/share/applications"
  done
  msg_ok "Application setup complete"
}

# --- Codium setup ---
setupCodium() {
  msg_info "Setting up Codium"
  if ! command -v codium >/dev/null; then
    msg_fail "Codium is not installed"
    return
  fi

  icon_themes=(
    "PKief.material-icon-theme"
    "PKief.material-product-icons"
  )
  color_themes=(
    "Catppuccin.catppuccin-vsc"
    "mvllow.rose-pine"
    "sainnhe.everforest"
    "arcticicestudio.nord-visual-studio-code"
    "enkia.tokyo-night"
    "jdinhlife.gruvbox"
  )
  extensions=(
    "esbenp.prettier-vscode"
    "formulahendry.code-runner"
  )

  for ext in "${icon_themes[@]}"; do
    codium --install-extension "$ext" && msg_ok "Installed $ext" || msg_fail "Failed to install $ext"
  done

  for ext in "${color_themes[@]}"; do
    codium --install-extension "$ext" && msg_ok "Installed $ext" || msg_fail "Failed to install $ext"
  done

  for ext in "${extensions[@]}"; do
    codium --install-extension "$ext" && msg_ok "Installed $ext" || msg_fail "Failed to install $ext"
  done

  msg_ok "Codium setup complete"
}

configSetup() {
  mkdir -p "$CONFIG/fish/themes"
  mkdir -p "$CONFIG/cava/themes"

  newCONFIG="$HYPRLAB/config"
  for d in "$newCONFIG"/*; do
    if [[ -d "$d" ]]; then
      dirname=$(basename "$d")
      mkdir -p "$CONFIG/$dirname"
      cp -r "$d/." "$CONFIG/$dirname/" || msg_fail "Error copying config $dirname"
    fi
  done
}

# --- Run all ---
installPkgs       #install dependancies
hyprlabClone      #clone hyprlab repo
backup            #Backup user configs
configSetup       #Copying configs into ~/.config/
setupFish         #fish shell
setupCodium       #Install default extensions
fontSetup         #Copying Fonts
iconApply         #Applying papirus icons
setupApplications #Copying .desktops
setupGpu          #Nvidia setup

export hyprlab="$HYPRLAB/bin/hyprlab"

"$HYPRLAB/scripts/others/theme-setup.sh" || msg_fail "Error running theme setup"
"$HYPRLAB/scripts/utils/screen.sh" || msg_fail "Failed to auto generate monitors configuration"
msg_ok "HyprLab setup complete! Please reboot to apply all changes."
notify-send "HyprLab installed successfully" "Reboot is required"

msg_info "Starting Neovim for LazyVim installation"
if command -v "$TERMINAL" >/dev/null 2>&1; then
  "$TERMINAL" nvim
else
  msg_info "Please start Neovim manually to setup LazyVim!"
fi
