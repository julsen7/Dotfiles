# Arch Linux Post-Installation Setup

This guide helps you set up a fresh Arch Linux installation, configure the network, and deploy your dotfiles using GNU Stow.

## Prerequisites

### 1. Base Installation & User Setup
Complete the manual base installation and create a non-root user with sudo privileges.
* 📖 [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)
* 📖 [General Recommendations & User Setup](https://wiki.archlinux.org/title/General_recommendations)

---

## Step-by-Step Configuration

### 2. Install Required Packages
Ensure you are logged into your new system and install the necessary base utilities:
```bash
sudo pacman -S base linux linux-firmware nano sudo stow
sudo pacman -S --needed git base-devel
```

### 3. Network Configuration (systemd-networkd)
Enable and configure the built-in systemd network daemon for wired connections.

1. Enable the network and DNS services:
   ```bash
   sudo systemctl enable --now systemd-networkd
   sudo systemctl enable --now systemd-resolved
   ```
2. Create a network configuration file:
   ```bash
   sudo nano /etc/systemd/network/20-wire.network
   ```
3. Paste the following configuration to enable DHCP on all Ethernet interfaces:
   ```ini
   [Match]
   Name=en*

   [Network]
   DHCP=yes
   ```
4. Verify your internet connection:
   ```bash
   ping -c 3 google.com
   ```

---

## Dotfiles & Software Deployment

### 4. Clone and Run the Installation Script
Clone your personal configuration files into your home directory and execute the custom post-install script. 

The script will automatically enable the **Multilib Repository**, install all official and AUR packages from your list, link your configurations via **GNU Stow**, and enable your system services.

```bash
git clone https://github.com/julsen7/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```
