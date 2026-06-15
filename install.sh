#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"
MD_FILE="$DOTFILES_DIR/Archinstall.md"

echo "==> Starte vollautomatische Post-Installation..."

if grep -q "^#\[multilib\]" /etc/pacman.conf; then
    echo "==> Aktiviere Multilib-Repository..."
    sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /etc/pacman.conf
fi

echo "==> Aktualisiere System-Datenbanken..."
sudo pacman -Syu --noconfirm

echo "==> Installiere Basis-Abhängigkeiten..."
sudo pacman -S --needed --noconfirm base-devel git stow

if ! command -v yay &> /dev/null; then
    echo "==> Installiere yay (AUR-Helper)..."
    YAY_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
    (cd "$YAY_DIR" && makepkg -si --noconfirm)
    rm -rf "$YAY_DIR"
fi

if [[ -f "$MD_FILE" ]]; then
    echo "==> Lese Paketliste aus Archinstall.md..."
    
    PACMAN_PKGS=""
    AUR_PKGS=""
    IS_AUR=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^#[[:space:]]*YAY ]]; then
            IS_AUR=1
            continue
        fi
        [[ "$line" =~ ^# || "$line" =~ ^- || -z "$line" ]] && continue
        
        line=$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')
        [[ -z "$line" ]] && continue

        if [ $IS_AUR -eq 1 ]; then
            AUR_PKGS="$AUR_PKGS $line"
        else
            PACMAN_PKGS="$PACMAN_PKGS $line"
        fi
    done < "$MD_FILE"

    if [[ -n "$PACMAN_PKGS" ]]; then
        echo "==> Installiere offizielle Arch-Pakete..."
        sudo pacman -S --needed --noconfirm $PACMAN_PKGS
    fi

    if [[ -n "$AUR_PKGS" ]]; then
        echo "==> Installiere AUR-Pakete via yay..."
        yay -S --needed --noconfirm $AUR_PKGS
    fi
else
    echo "[FEHLER] Archinstall.md wurde unter $MD_FILE nicht gefunden!"
    exit 1
fi

if [[ -d "$DOTFILES_DIR" ]]; then
    echo "==> Verlinke Dotfiles mit GNU Stow..."
    cd "$DOTFILES_DIR"
    
    stow -R .
else
    echo "[WARNUNG] Dotfiles-Ordner nicht gefunden! Überspringe Stowing."
fi

echo "==> Aktiviere Systemd-Dienste..."
for service in systemd-networkd.service systemd-resolved.service bluetooth.service ly@tty1.service power-profiles-daemon.service; do
    if systemctl list-unit-files | grep -q "^$service"; then
        sudo systemctl enable --now "$service"
    else
        echo "[INFO] Dienst $service nicht gefunden. Überspringe."
    fi
done

echo "========================================= "
echo " Installation abgeschlossen! Starte neu."
echo "========================================="
