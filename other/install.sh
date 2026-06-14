#!/bin/bash

set -euo pipefail

echo "==> Aktualisiere System..."
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

if [[ -f "pkglist.txt" ]]; then
    echo "==> Installiere offizielle Pakete aus pkglist.txt..."
    
    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        
        echo "    Installiere: $package"
        sudo pacman -S --needed --noconfirm "$package" || echo "[FEHLER] Paket $package konnte nicht installiert werden!"
    done < "pkglist.txt"
else
    echo "[WARNUNG] pkglist.txt nicht gefunden!"
fi

if [[ -f "aurlist.txt" ]]; then
    echo "==> Installiere AUR-Pakete aus aurlist.txt..."
    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" =~ ^# ]] && continue
        
        echo "    Installiere AUR: $package"
        yay -S --needed --noconfirm "$package" || echo "[FEHLER] AUR-Paket $package konnte nicht installiert werden!"
    done < "aurlist.txt"
else
    echo "[INFO] Keine AUR-Paketliste gefunden."
fi

echo "==> Verlinke Dotfiles mit GNU Stow..."
if [[ -d ~/dotfiles ]]; then
    cd ~/dotfiles
    
    for dir in */; do
        dir=${dir%/}
        
        if [[ "$dir" != ".git" && "$dir" != "other" ]]; then
            echo "    Stowing: $dir"
            stow -R "$dir"
        fi
    done
    cd - > /dev/null
else
    echo "[WARNUNG] ~/dotfiles Ordner wurde nicht gefunden! Überspringe Stowing."
fi

if [[ -f ~/dotfiles/config.ini ]]; then
    echo "==> Konfiguriere Ly Display Manager..."
    sudo mkdir -p /etc/ly/
    sudo cp ~/dotfiles/config.ini /etc/ly/
fi

echo "==> Aktiviere Systemd-Dienste..."
for service in NetworkManager bluetooth.service ly.service ufw.service power-profiles-daemon.service; do
    if systemctl list-unit-files | grep -q "^$service"; then
        sudo systemctl enable "$service"
    else
        echo "[INFO] Dienst $service nicht gefunden oder Name abweichend. Überspringe."
    fi
done

echo "==> Aktiviere UFW..."
sudo ufw --force enable

echo "========================================= "
echo " Installation abgeschlossen! Starte neu."
echo "========================================="
