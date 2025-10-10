#!/usr/bin/env bash

#
# arch linux post-install setup script
#
# this script automates the setup of a fresh arch linux installation
# according to my preferences.
#

# exit immediately if a command fails
set -e

# --- package lists ---
# add or remove packages here as you see fit.

# packages from official arch repositories
pacman_packages=(
    # essentials
    amd-ucode
    ark
    base-devel
    btop
    dnsmasq
    dolphin
    fastfetch
    fish
    git
    iwd
    hostapd
    kate
    kio-admin
    konsole
    nano
    noto-fonts
    noto-fonts-emoji
    openssh
    packagekit-qt6
    pacman-contrib
    power-profiles-daemon
    plasma-meta
    os-prober
    reflector
    smartmontools
    unrar
    wget
    xdg-utils

    # applications
    firefox
    mpv
    gwenview
    filelight
    filezilla
    obs-studio
    qbittorrent
    bitwarden
    steam
    lutris
    wine
    mangohud
    gamemode
    nvidia-settings
)

# packages from the arch user repository (aur)
aur_packages=(
    vesktop
    spotify
    music-presence-bin
    surfshark-client
)


# --- script execution ---

echo ">>> starting arch linux post-install setup..."

# step 1: check for and install pacman packages
echo ">>> checking for already installed packages..."
already_installed=()
for pkg in "${pacman_packages[@]}"; do
    if pacman -q "$pkg" &> /dev/null; then
        already_installed+=("$pkg")
    fi
done

echo ">>> updating system and installing packages from official repositories..."
sudo pacman -Syu --needed --noconfirm "${pacman_packages[@]}"

# report which packages were already installed
if [ ${#already_installed[@]} -gt 0 ]; then
    echo "---"
    echo ">>> the following packages were already installed and were skipped:"
    for pkg in "${already_installed[@]}"; do
        echo "    - $pkg"
    done
    echo "---"
fi


# step 2: install aur helper (paru)
echo ">>> installing aur helper 'paru'..."
temp_dir=$(mktemp -d)
cd "$temp_dir"
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ~
rm -rf "$temp_dir"


# step 3: install aur packages
echo ">>> installing packages from the aur..."
paru -S --needed --noconfirm "${aur_packages[@]}"


# step 4: configure grub
echo ">>> configuring grub to enable os-prober..."
sudo sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg


# step 5: change default shell to fish
echo ">>> changing default shell to fish for user $user..."
chsh -s "$(which fish)"
echo "shell changed to fish. please log out and back in for it to take effect."


# step 6: configure fish shell
echo ">>> creating fish configuration..."
mkdir -p ~/.config/fish
cat <<'eof' > ~/.config/fish/config.fish
# run fastfetch on startup if the shell is interactive
if status is-interactive
    fastfetch
end

# disable fish greeting
set fish_greeting

# create aliases
alias fetch="fastfetch"
eof

echo "------------------------------------------"
echo ">>> setup complete! <<<"
echo "reboot to apply all changes."
echo "run 'sudo systemctl reboot' to reboot"
echo "------------------------------------------"
