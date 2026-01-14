#!/usr/bin/env bash

set -euo pipefail

clear

# --- Packages ---
pkgs=(
  "nautilus" "kitty" "adw-gtk-theme" "vesktop" "vscodium" "waybar"
  "nvim" "cava" "btop" "rofi" "hyprshot" "hyprlock" "swww" "swaync"
  "wlogout" "wf-recorder" "slurp" "ttf-jetbrains-mono-nerd" "papirus-folders-git"
  "starship" "zenity" "eza" "fish" "wl-clipboard" "python3" "cliphist" "matugen"
  "base-devel" "git" "wget" "nvibrant" "pavucontrol" "blueman" "python"
  "nm-connection-editor" "mpris" "yt-dlp" "mpv-mpris" "mpv" "playerctl" "hyprsunset"
)

# --- Logging ---
LOGFILE="$HOME/hyprlab_install.log"
touch "$LOGFILE"

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] $message" >> "$LOGFILE"

    echo -e "[$level] $message"
}

C_RESET="\e[0m"; C_GREEN="\e[32m"; C_RED="\e[31m"; C_BLUE="\e[34m"

msg_ok()   { log "${C_GREEN}OK${C_RESET}"  "$*"; }
msg_fail() { log "${C_RED}ERROR${C_RESET}" "$*"; }
msg_info() { log "${C_BLUE}INFO${C_RESET}" "$*"; }


# --- Variables ---
TERMINAL="${TERMINAL:-kitty}"
gitURL="https://github.com/Sash1ro/HyprLab.git"
CONFIG="$HOME/.config"
HYPRLAB="$CONFIG/hyprlab"
BACKUP_DIR="$HOME/conf-backups"
FONT_DIR="$HYPRLAB/assets/fonts/SF-Pro"
SYSTEM_FONT_DIR="/usr/local/share/fonts/otf"

# --- Preliminary checks ---
if [ "$EUID" -eq 0 ]; then
    msg_fail "Do not run this script as root."
    exit 1
fi

if ! command -v pacman >/dev/null; then
  msg_fail "Only Arch-based distros supported"
  exit 1
fi

if ! pacman -Qi hyprland >/dev/null 2>&1; then
  msg_fail "Please install Hyprland first!"
  exit 1
fi

if [[ ! -d "$CONFIG" ]]; then
  msg_fail "No config folder found at $CONFIG"
  exit 1
fi

# --- Sudo keep-alive ---
msg_info "Requesting sudo access..."
sudo -v || (msg_fail "sudo required" && exit 1)
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Backup configs ---
backup() {
  dirs=("hypr" "matugen" "fish" "fastfetch" "kitty" "swaync" "waybar" "wlogout" "rofi" "nvim" "cava" "gtk-3.0" "gtk-4.0" "btop")
  files=("starship.toml")
  msg_info "Backing up configs"
  mkdir -p "$BACKUP_DIR"
  for d in "${dirs[@]}"; do
    [[ -d "$CONFIG/$d" ]] && mv "$CONFIG/$d" "$BACKUP_DIR/$d.bak" && mkdir -p "$CONFIG/$d"
  done
  for f in "${files[@]}"; do
    [[ -f "$CONFIG/$f" ]] && mv "$CONFIG/$f" "$BACKUP_DIR/$f.bak"
  done
  msg_ok "Backup complete"
}

# --- Yay install ---
yayInstall() {
  msg_info "Installing dependencies for yay..."
  sudo pacman -S --needed --noconfirm base-devel git
  msg_info "Cloning yay..."
  cd /tmp || exit
  git clone "https://aur.archlinux.org/yay.git"
  cd yay || exit
  msg_info "Building and installing yay..."
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
  msg_ok "Yay installation complete"
}

# --- Package installation ---
installPkgs() {
  if ! command -v yay >/dev/null 2>&1; then
    yayInstall || (msg_fail "Failed to install yay" && exit 1)
  fi

  [[ ! -d "$HOME/.local/share/icons/Papirus" ]] && \
    wget -qO- "https://git.io/papirus-icon-theme-install" | env DESTDIR="$HOME/.local/share/icons" sh

  msg_info "Updating package database..."
  yay -Sy --noconfirm

  for pkg in "${pkgs[@]}"; do
    msg_info "Checking: $pkg"
    if ! yay -Qi "$pkg" >/dev/null 2>&1; then
      msg_info "Installing $pkg"
      yay -S --noconfirm --needed "$pkg" &&
        msg_ok "$pkg installed" ||
        (msg_fail "Failed to install $pkg" && exit 1)
    else
      msg_info "$pkg already installed"
    fi
  done

  msg_ok "All packages installed"
}

# --- Fish shell setup ---
setupFish() {
  local fishConfig="$CONFIG/fish/config.fish"
  mkdir -p "$(dirname "$fishConfig")"
  [[ ! -f "$fishConfig" ]] && touch "$fishConfig"

  local fishPath
  fishPath=$(command -v fish)
  if ! grep -q "$fishPath" /etc/shells; then
    msg_info "Adding $fishPath to /etc/shells"
    echo "$fishPath" | sudo tee -a /etc/shells >/dev/null
  fi

  msg_info "Changing default shell to fish"
  chsh -s "$fishPath" && msg_ok "Default shell set to fish" || msg_fail "Failed to change shell"
}

# --- Clone HyprLab ---
hyprlabClone() {
  if [[ ! -d "$HYPRLAB" ]]; then
    msg_info "Cloning HyprLab..."
    git clone "$gitURL" "$HYPRLAB"
  else
    msg_info "HyprLab already exists"
  fi
  msg_ok "HyprLab ready"

  find $HYPRLAB -type f -name "*.sh" -exec chmod +x {} \;
  find $HYPRLAB -type f -name "hyprlab" -exec chmod +x {} \;
}

# --- Font setup ---
fontSetup() {
  msg_info "Copying fonts..."
  if [[ -d "$FONT_DIR" && $(ls "$FONT_DIR"/*.otf 2>/dev/null | wc -l) -gt 0 ]]; then
    sudo mkdir -p "$SYSTEM_FONT_DIR/sf-pro"
    sudo cp "$FONT_DIR"/*.otf "$SYSTEM_FONT_DIR/sf-pro"
    fc-cache -fv
    msg_ok "Fonts installed"
  else
    msg_fail "No fonts found in $FONT_DIR"
  fi
}

# --- Icons ---
iconApply() {
  if command -v papirus-folders >/dev/null; then
    msg_info "Applying Papirus icons..."
    papirus-folders -C blue && msg_ok "Icons applied"
  fi
}

# --- GPU detection ---
setupGpu() {
  msg_info "Detecting GPU..."
  if lspci | grep -iq nvidia; then
    msg_info "NVIDIA GPU detected"
    if ! grep -Fxq "source=~/.config/hyprlab/hyprland/conf/nvidia.conf" "$HOME/.config/hyprlab/hyprland/conf/env.conf" 2>/dev/null; then
      echo "source=~/.config/hyprlab/hyprland/conf/nvidia.conf" >> "$HOME/.config/hyprlab/hyprland/conf/env.conf"
    fi
  else
    msg_info "Compatible GPU detected"
  fi
  msg_ok "GPU setup done"
}

# --- Copy applications ---
setupApplications() {
  msg_info "Copying .desktop files..."
  local apps="$HYPRLAB/applications"
  [[ -d "$apps" ]] && cp -a "$apps/." "$HOME/.local/share/applications" && msg_ok "Applications ready"
}

# --- Codium setup ---
setupCodium() {
  command -v codium >/dev/null || { msg_fail "Codium not installed"; return; }
  msg_info "Installing Codium extensions..."
  local exts=( "PKief.material-icon-theme" "Catppuccin.catppuccin-vsc" "esbenp.prettier-vscode" )
  for ext in "${exts[@]}"; do
    codium --install-extension "$ext" && msg_ok "Installed $ext" || msg_fail "Failed $ext"
  done
  msg_ok "Codium setup complete"
}

# --- Configs ---
configSetup() {
  msg_info "Copying configs..."
  mkdir -p "$CONFIG/fish/themes" "$CONFIG/cava/themes"
  for d in "$HYPRLAB/config"/*; do
    [[ -d "$d" ]] || continue
    dirname=$(basename "$d")
    mkdir -p "$CONFIG/$dirname"
    cp -r "$d/." "$CONFIG/$dirname/" || msg_fail "Error copying $dirname"
  done
  ln -sfn "$HYPRLAB/hyprland/profiles/default" "$HYPRLAB/hyprland/profiles/current"
  ln -sfn "$HYPRLAB/hyprland/monitors_profile/default.conf" "$HYPRLAB/hyprland/monitors_profile/current"
}

# --- Run everything ---
backup
installPkgs
hyprlabClone
configSetup
setupFish
setupApplications
setupGpu
setupCodium
fontSetup
iconApply

export PATH="$HYPRLAB/scripts/bin:$PATH"

[[ -x "$HYPRLAB/scripts/others/theme-setup.sh" ]] && "$HYPRLAB/scripts/others/theme-setup.sh" || msg_fail "Theme setup failed"
[[ -x "$HYPRLAB/scripts/utils/screen.sh" ]] && "$HYPRLAB/scripts/utils/screen.sh" || msg_fail "Screen config failed"

msg_ok "HyprLab installation complete! Reboot recommended."
notify-send "HyprLab installed successfully" "Reboot is required"

# LazyVim initialisation
msg_info "Running Neovim headless for LazyVim..."
nvim --headless +Lazy! +qall && msg_ok "LazyVim initialized" || msg_fail "LazyVim setup failed"

trap 'kill $(jobs -p)' EXIT

