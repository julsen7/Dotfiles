#!/usr/bin/env bash

set -euo pipefail

GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
RED="$(tput setaf 1)"
NC="$(tput sgr0)"

DOTFILES_DIR="$HOME/Dotfiles"
WALLPAPER_DIR="$DOTFILES_DIR/wallpaper"
PACKAGE_FILE="$DOTFILES_DIR/packages.md"

echo "${GREEN}==>${NC} Starting Installation..."

if [ "$EUID" -eq 0 ]; then
    echo "${RED}Error:${NC} No root allowed!"
    exit 1
fi

echo "${GREEN}==>${NC} Activating Multilib-Repository..."
sudo sed -i -z 's|#\[multilib\]\n#Include = /etc/pacman.d/mirrorlist|\[multilib\]\nInclude = /etc/pacman.d/mirrorlist|' /etc/pacman.conf

echo "${GREEN}==>${NC} Updating System-Databases..."
sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    echo "${GREEN}==>${NC} Installing yay..."
    cd "$HOME"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    rm -rf "$HOME/yay"
fi
cd "$DOTFILES_DIR"

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "${RED}Error:${NC} $PACKAGE_FILE not found!"
    exit 1
fi

echo "${GREEN}==>${NC} Installing packages from $PACKAGE_FILE..."
while IFS= read -r line || [ -n "$line" ]; do
    trimmed="${line#"${line%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

    [[ -z "$trimmed" ]] && continue
    [[ "$trimmed" =~ ^# ]] && continue

    package=$(echo "$trimmed" | sed -E 's/^([-*]|([0-9]+\.))\s+//; s/`//g')

    [[ -z "$package" ]] && continue

    echo "Installing: $package"
    yay -S --needed --noconfirm "$package" || echo "${YELLOW}Warning:${NC} Failed to install $package"
done < "$PACKAGE_FILE"
echo "All packages processed!"

echo "${GREEN}==>${NC} Preparing Home Directory for Stow..."
cd "$DOTFILES_DIR"
find . -type f -not -path '*/.*' -not -path './assets/*' -not -path './wallpaper/*' -not -name 'packages.md' -not -name 'README.md' | while read -r file; do
    target="$HOME/${file#./}"
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        echo "Removing existing config file to prevent Stow conflict: $target"
        rm -f "$target"
    fi
done

echo "${GREEN}==>${NC} Linking Dotfiles with GNU Stow..."
stow -v -R .

echo "${GREEN}==>${NC} Configuring ly..."
if [ -f /etc/ly/config.ini ]; then
    sudo mkdir -p /etc/ly/
    sudo sed -i -e 's|animation = matrix|animation = dur_file|' -e 's|dur_file_path = /etc/ly/example.dur|dur_file_path = /etc/ly/blackhole.dur|' -e 's/bigclock = null/bigclock = en/' /etc/ly/config.ini
    sudo cp "$DOTFILES_DIR/assets/blackhole.dur" "/etc/ly/blackhole.dur"
else
    echo "${YELLOW}Warning:${NC} /etc/ly/config.ini not found."
fi

echo "${GREEN}==>${NC} Activating services..."
sudo systemctl enable NetworkManager.service
sudo systemctl enable ly@tty1.service
sudo systemctl enable bluetooth.service
sudo systemctl enable ufw.service

systemctl --user enable pipewire.service
systemctl --user enable pipewire-pulse.service
systemctl --user enable wireplumber.service
systemctl --user enable hyprpolkitagent.service 
systemctl --user enable waybar.service

echo "${GREEN}==>${NC} Activating scripts..."
if [ -f "$DOTFILES_DIR/.config/waybar/scripts/weather.sh" ]; then
    chmod +x "$DOTFILES_DIR/.config/waybar/scripts/weather.sh"
else
    echo "${YELLOW}Warning:${NC} weather.sh not found, skipping."
fi

if [ -d /opt/spotify ]; then
    sudo chmod a+wr /opt/spotify
    sudo chmod -R a+wr /opt/spotify/Apps -R
else
    echo "${YELLOW}Warning:${NC} Spotify not installed, skipping."
fi

echo "${GREEN}==>${NC} Installing VSCode extensions..."
# Diagnose-Ausgabe: Zeigt dir im Terminal, welchen Pfad das Skript genau prüft
echo "Debugging: Looking for extensions file at: $DOTFILES_DIR/assets/extensions.txt"

if [ -f "$DOTFILES_DIR/assets/extensions.txt" ]; then
    while IFS= read -r ext || [ -n "$ext" ]; do
        ext=$(echo "$ext" | tr -d '\r')
        [ -n "$ext" ] && [[ ! "$ext" =~ ^# ]] && code --install-extension "$ext"
    done < "$DOTFILES_DIR/assets/extensions.txt"
else
    echo "${YELLOW}Warning:${NC} extensions.txt not found at $DOTFILES_DIR/assets/extensions.txt, skipping."
fi

echo "========================================"
echo "  Installation finished! Please reboot  "
echo "========================================"
