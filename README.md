# Arch Linux Installation & Post-Setup Guide

This guide covers the manual base installation of Arch Linux and the automated deployment of system configuration files using GNU Stow.

---

## 1. Base Installation (Arch ISO)

Boot from your Arch Linux live media and complete these initial configuration steps an donly change these.

```bash
keyboard layout de-latin1
locale language de_DE.UTF-8
disk configuration use best afford, ext4 home-no
authentication rootpw
user julsen <pw> sudo-yes
profile minimal
timezone: Europe/Berlin
install: yes

automatisch-installiert -Qe:
amd-ucode
base
efibootmgr
linux
linux-firmware
sudo
zram-generator
```

---

## 2. Dotfiles & Software Deployment

Log in as `julsen` and execute your deployment scripts directly within your personal home directory.

```bash
sudo pacman -S --needed git base-devel stow
git clone https://github.com/julsen7/Dotfiles
cd ~/Dotfiles
chmod +x install.sh
./install.sh
```

Config github to use correct authentication.

```bash
gh auth login
```
