#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"

echo "==> Starte Installation..."

echo "==> Aktiviere Multilib-Repository..."
nano sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

echo "==> Installiere yay (AUR-Helper)..."
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

echo "==> Aktualisiere System-Datenbanken..."
sudo pacman -Syu --noconfirm

PACKAGE_FILE="packages.md"

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "Error: $PACKAGE_FILE not found."
    exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
    trimmed=$(echo "$line" | xargs)

    [[ -z "$trimmed" ]] && continue

    [[ "$trimmed" =~ ^# ]] && continue

    package=$(echo "$trimmed" | sed -E 's/^([-*]|([0-9]+\.))\s+//; s/`//g')

    echo "Installing: $package"
    yay -S --noconfirm "$package"
done < "$PACKAGE_FILE"
echo "All packages processed!"


echo "==> Verlinke Dotfiles mit GNU Stow..."
cd "$DOTFILES_DIR"
stow -R .

echo "==> Copy ly Configuration..."
sudo mkdir -p /etc/ly/
sudo cp "$DOTFILES_DIR/config.ini" /etc/ly/

echo "==> Aktiviere Systemd-Dienste..."
sudo systemctl enable --now ly@tty1.service

echo "==> Generiere Wallpaper-Theme ..."
wal -i "wallpapers/wallpaper.webp"


echo "===================================== "
echo " Installation finished! Please reboot."
echo "======================================"
