#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"
TARGET_WALLPAPER_DIR="/home/julsen/wallpaper"

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
    trimmed="${line#"${line%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

    [[ -z "$trimmed" ]] && continue
    [[ "$trimmed" =~ ^# ]] && continue

    package=$(echo "$trimmed" | sed -E 's/^([-*]|([0-9]+\.))\s+//; s/`//g')

    [[ -z "$package" ]] && continue

    echo "Installing: $package"
    yay -S --noconfirm "$package" || echo "Warning: Failed to install $package"
done < "$PACKAGE_FILE"
echo "All packages processed!"

echo "==> Linking Dotfiles with GNU Stow..."
cd "$DOTFILES_DIR"
stow --adopt -R .
git reset --hard HEAD 2>/dev/null || true

echo "==> Configuring ly ..."
if [ -f /etc/ly/config.ini ]; then
    sudo mkdir -p /etc/ly/
    sudo sed -i 's/^#\?\s*animation\s*=.*/animation = matrix/' /etc/ly/config.ini
else
    echo "Warning: /etc/ly/config.ini not found."
fi

# Commands to check status
# systemctl [--user] list-unit-files --state=enabled
# systemctl [--user] status XXX

echo "==> Activating Services..."
sudo systemctl enable NetworkManager.service
sudo systemctl enable ly@tty1.service
sudo systemctl enable bluetooth.service
sudo systemctl enable ufw.service

systemctl --user enable pipewire.service
systemctl --user enable pipewire-pulse.service
systemctl --user enable wireplumber.service
systemctl --user enable hyprpolkitagent.service 
systemctl --user enable waybar.service
systemctl --user enable hyprpaper.service

echo "==> Activating waybar scripts"
if [ -d "$DOTFILES_DIR/.config/waybar" ]; then
    cd "$DOTFILES_DIR/.config/waybar"
    chmod +x weather.sh timer.sh check-updates.sh install-updates.sh 2>/dev/null || echo "Warning: Some scripts are missing!"
fi

cd "$DOTFILES_DIR"

echo "==> Generating Wallpaper-Theme ..."
WALLPAPER_PATH=$(find "$DOTFILES_DIR/wallpapers" -type f \( -name "*.webp" -o -name "*.jpg" -o -name "*.png" \) -print -quit 2>/dev/null)

if [ -n "$WALLPAPER_PATH" ] && [ -f "$WALLPAPER_PATH" ]; then
    mkdir -p "$TARGET_WALLPAPER_DIR"

    cp "$DOTFILES_DIR"/wallpapers/* "$TARGET_WALLPAPER_DIR/" 2>/dev/null || true
    
    cp "$WALLPAPER_PATH" "$TARGET_WALLPAPER_DIR/Mountain.webp"

    matugen image "$TARGET_WALLPAPER_DIR/Mountain.webp" -m "dark"
else
    echo "Warning: No wallpaper found in $DOTFILES_DIR/wallpapers/"
fi

echo "===================================== "
echo " Installation finished! Please reboot."
echo "======================================"
