#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"

echo "==> Starting Installation..."

if [ "$EUID" -eq 0 ]; then
    echo "Error: No root allowed!"
    exit 1
fi

echo "==> Activating Multilib-Repository..."
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

echo "==> Updating System-Databases..."
sudo pacman -Syu --noconfirm

echo "==> Installing yay..."
cd /tmp
rm -rf yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd "$DOTFILES_DIR"
rm -rf /tmp/yay

PACKAGE_FILE="packages.md"

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: $PACKAGE_FILE not found!"
    exit 1
fi

echo "==> Installing packages from $PACKAGE_FILE..."
while IFS= read -r line || [ -n "$line" ]; do
    trimmed=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    [[ -z "$trimmed" ]] && continue
    [[ "$trimmed" =~ ^# ]] && continue

    package=$(echo "$trimmed" | sed -E 's/^([-*]|([0-9]+\.))\s+//; s/`//g')

    echo "Installing: $package"
    yay -S --noconfirm "$package"
done < "$PACKAGE_FILE"
echo "All packages processed!"

echo "==> Linking Dotfiles with GNU Stow..."
cd "$DOTFILES_DIR"
stow -R .

echo "==> Copy ly Configuration..."
sudo mkdir -p /etc/ly/
if [ -f "$DOTFILES_DIR/config.ini" ]; then
    sudo cp "$DOTFILES_DIR/config.ini" /etc/ly/
else
    echo "Warning: config.ini not found in $DOTFILES_DIR!"
fi

echo "==> Activating Services..."
sudo systemctl enable NetworkManager
sudo systemctl enable ly@tty1.service
systemctl --user enable hyprpolkitagent

echo "==> Activating waybar scripts"
if [ -d "$DOTFILES_DIR/.config/waybar" ]; then
    cd "$DOTFILES_DIR/.config/waybar"
    chmod +x weather.sh timer.sh check-updates.sh install-updates.sh 2>/dev/null || echo "Warning: Some scripts are missing!"
fi

cd "$DOTFILES_DIR"

echo "==> Generating Wallpaper-Theme ..."
if [ -f "wallpapers/wallpaper.webp" ]; then
    wal -i "wallpapers/wallpaper.webp"
else
    echo "Warning: wallpapers/wallpaper.webp not found!"
fi

echo "===================================== "
echo " Installation finished! Please reboot."
echo "======================================"
