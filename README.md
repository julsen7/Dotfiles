# Arch Linux Installation & Post-Setup Guide

This guide covers the manual base installation of Arch Linux and the automated deployment of system configuration files using GNU Stow.

---

## 1. Base Installation (Arch ISO)

Boot from your Arch Linux live media and complete these initial configuration steps.

---

## 1.1: archinstall
keyboard layout de-latin1
```bash
locale language de_DE.UTF-8
disk configuration use best afford (1 efi, 4 swap, rest main) hauptfestplatte ext4 home-no
swap enabled zstd
bootloader systemd-boot uki enabled
kernel linux
hostname archlinux
authentication rootpw
user julsen <pw> sudo-yes
profile minimal
applications: bluetooth yes, audio pipewire, print no, power management power-profiles daemon, firewall ufw, additional fonts noto-fonts noto-fonts-emoji
network configuration: network manager
pacman-color yes
timezone: Europe/Berlin
automatic time sync enabled
install: yes
wait ... reboot system

installiert automatisch dann:
amd-ucode
base
base-devel
bluez
bluez-utils
efibootmgr
git
gst-plugin-pipewire
libpulse
linux
linux-firmware
lvm2
pipewire
pipewire-alsa
pipewire-jack
pipewire-pulse
power-profiles-daemon
sof-firmware
sudo
ufw
wireplumber
zram-generator
```

---

## 1.2: manually

Follow Instructions on [Arch Wiki](https://wiki.archlinux.org/title/Installation_guide)
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
