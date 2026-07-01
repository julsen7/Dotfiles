#!/usr/bin/env bash

set -euo pipefail

GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
RED="$(tput setaf 1)"
NC="$(tput sgr0)"

DOTFILES_DIR="$HOME/Dotfiles"
WALLPAPER_DIR="$DOTFILES_DIR/wallpaper"
PACKAGE_FILE="$HOME/Dotfiles/packages.md"

echo "${GREEN}==>${NC} Starting Installation..."

if [ "$EUID" -eq 0 ]; then
    echo "${RED}Error:${NC} No root allowed!"
    exit 1
fi

echo "${GREEN}==>${NC} Activating Multilib-Repository..."
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

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

echo "${GREEN}==>${NC} Linking Dotfiles with GNU Stow..."
cd "$DOTFILES_DIR"
stow --adopt -R .
git reset --hard HEAD 2>/dev/null || true

echo "${GREEN}==>${NC} Configuring ly..."
if [ -f /etc/ly/config.ini ]; then
    sudo mkdir -p /etc/ly/
    sudo sed -i 's/^#\?\s*animation\s*=.*/animation = matrix/' /etc/ly/config.ini
else
    echo "${YELLOW}Warning:${NC} /etc/ly/config.ini not found."
fi

# Commands to check status
# systemctl [--user] list-unit-files --state=enabled
# systemctl [--user] status XXX

echo "${GREEN}==>${NC} Activating Services..."
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
chmod +x "$DOTFILES_DIR/.config/waybar/weather.sh" 2>/dev/null
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

echo "${GREEN}==>${NC} Setting Wallpaper..."
matugen image "$WALLPAPER_DIR/Mountain.jpg" --source-color-index 0 >/dev/null 2>&1

echo "========================================"
echo "  Installation finished! Please reboot  "
echo "========================================"
