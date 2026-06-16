# Arch Linux Installation & Post-Setup Guide

This guide covers the manual base installation of Arch Linux and the automated deployment of system configuration files using GNU Stow.

---

## 1. Base Installation (Arch ISO)

Boot from your Arch Linux live media and complete these initial configuration steps.

### Keyboard & Time
```bash
loadkeys de-latin1
cat /sys/firmware/efi/fw_platform_size # Should return 64
timedatectl set-ntp true
```

### Network Configuration (WIFI)
*Skip this step if you are using a wired Ethernet connection.*
```bash
iwctl station wlan0 connect <SSID> --passphrase <password>
ping -c 3 google.com
```

### Drive Partitioning & Formatting
```bash
fdisk /dev/nvme0n1
# Partition drive /dev/nvme0n1 using fdisk:
# Press 'g' to create a new GPT partition table.
# Press 'n' -> 1 -> Enter -> +1G -> 't' -> 1 -> 1 (EFI System)
# Press 'n' -> 2 -> Enter -> +4G -> 't' -> 2 -> 19 (Linux swap)
# Press 'n' -> 3 -> Enter -> Enter -> 't' -> 3 -> 20 (Linux filesystem)
# Press 'w' to write changes and exit.

# Create file systems
mkfs.fat -F 32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3

# Mount file systems
mount /dev/nvme0n1p3 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p2
lsblk # for testing
```

### System Pacstrap & Chroot
```bash
pacstrap -K /mnt base linux linux-firmware nano sudo
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt
```

### Base Configuration (Inside Chroot)
```bash
# Time zone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Localization (Uncomment de_DE.UTF-8 UTF-8 in /etc/locale.gen first)
nano /etc/locale.gen
locale-gen

# System files
echo "LANG=de_DE.UTF-8" > /etc/locale.conf
echo "KEYMAP=de-latin1" > /etc/vconsole.conf
echo "archlinux" > /etc/hostname

# Initramfs & Root Password
passwd
```

### Bootloader Setup (systemd-boot mit UKI)
```bash
# 1. Bootloader installieren (Auflösung wird automatisch nativ gesetzt)
bootctl install
echo "timeout 3" > /boot/loader/loader.conf

# 2. Kernel-Parameter vollautomatisiert übergeben
echo "root=PARTUUID=\$(blkid -s PARTUUID -o value /dev/nvme0n1p3) rw" > /etc/kernel/cmdline

# 3. mkinitcpio für die automatische UKI-Erstellung konfigurieren
sed -i 's/#default_uki=/default_uki=/g' /etc/mkinitcpio.d/linux.preset
sed -i 's/#fallback_uki=/fallback_uki=/g' /etc/mkinitcpio.d/linux.preset
sed -i 's/default_image=/#default_image=/g' /etc/mkinitcpio.d/linux.preset
sed -i 's/fallback_image=/#fallback_image=/g' /etc/mkinitcpio.d/linux.preset

# 4. Verzeichnis erstellen und Image generieren
mkdir -p /boot/EFI/Linux
mkinitcpio -P
```

### Create System User & Sudo Access
```bash
# User direkt im Chroot erstellen
useradd -m -G wheel -s /bin/bash julsen
passwd julsen

# %wheel Gruppe freischalten
EDITOR=nano visudo
```

### Finalize Installation
```bash
exit
umount -R /mnt
reboot
```

---

## 2. Post-Installation Configuration

Log into your fresh system installation as `root` to configure your main environment.

### Core Utilities
```bash
pacman -S --needed git base-devel
```

### Wired Network Service (systemd-networkd)
```bash
systemctl enable --now systemd-networkd systemd-resolved

# Create network configuration profile
cat <<EOF > /etc/systemd/network/20-wire.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF'

ping -c 3 google.com
```

---

## 3. Dotfiles & Software Deployment

Execute your deployment scripts directly within your personal home directory.

```bash
git clone https://github.com/julsen7/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```
