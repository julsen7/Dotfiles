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
ping google.com
```

### Drive Partitioning & Formatting
```bash
fdisk /dev/nvme0n1
# Partition drive /dev/nvme0n1 using fdisk:
# Press 'g' to create a new GPT partition table.
# Press 'n' -> 1 -> Enter -> +1G -> 't' -> 1 (EFI system partition)
# Press 'n' -> 2 -> Enter -> +4G -> 't' -> 2 -> 19 (Linux swap)
# Press 'n' -> 3 -> Enter -> Enter (Linux root partition)
# Press 'w' to write changes and exit.

# Create file systems
mkfs.fat -F 32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3

# Mount file systems
mount /dev/nvme0n1p3 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
swapon /dev/nvme0n1p2
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
mkinitcpio -P
passwd
```

### Bootloader Setup (systemd-boot)
```bash
bootctl install

# Configure loader settings
cat <<EOF > /boot/loader/loader.conf
default arch.conf
timeout 3
console-mode max
EOF

# Copy the PARTUUID output from this command for the next step:
blkid -s PARTUUID -o value /dev/nvme0n1p3

# Create the boot entry (Replace <UUID> with the output from above)
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=<UUID> rw
EOF
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
systemctl enable --now systemd-networkd
systemctl enable --now systemd-resolved

# Create network configuration profile
cat <<EOF > /etc/systemd/network/20-wire.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF

ping -c 3 google.com
```

### Create System User
```bash
# Create user with wheel group access
useradd -m -G wheel <your_username>
passwd <your_username>

# Uncomment the "%wheel ALL=(ALL:ALL) ALL" line to grant sudo access
EDITOR=nano visudo
```

---

## 3. Dotfiles & Software Deployment

Log out of the root user account, sign back into your newly created personal profile, and execute your deployment scripts.

```bash
git clone https://github.com/julsen7/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```
