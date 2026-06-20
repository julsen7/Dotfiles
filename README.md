# 1. Base Installation (Arch ISO)

Boot from your Arch Linux live media with archinstall and complete these initial configuration changes.

```bash
keyboard layout de-latin1
locale language de_DE.UTF-8
disk configuration use best afford, ext4, home-no
authentication rootpw
user julsen <pw> sudo-yes
profile minimal
Network configuration: Networkmanager
Timezone: Europe/Berlin
```

# 2. Dotfiles

Log in as your user.

```bash
sudo pacman -S --needed git base-devel
git clone https://github.com/julsen7/Dotfiles
cd ~/Dotfiles
chmod +x install.sh
./install.sh
```

Config github to use correct authentication.

```bash
gh auth login
```
