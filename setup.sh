#!/bin/bash

# exit immediately if a command exits with a non-zero status.
set -e

# --- pacman packages ---
echo "--- installing pacman packages ---"

# list of packages
pacman_packages=(
    # essentials
    amd-ucode
    base-devel
    btop
    dnsmasq
    iwd
    hostapd
    openssh
    pacman-contrib
    power-profiles-daemon
    reflector
    smartmontools
    os-prober
    git
    wget
    xdg-utils

    # utilities
    plasma-meta
    ark
    dolphin
    kate
    kio-admin
    konsole
    packagekit-qt6
    noto-fonts
    noto-fonts-emoji
    
    # terminal
    fastfetch
    nano
    zsh
    zsh-autosuggestions

    # file management 
    unrar

    # applications
    firefox
    mpv
    gwenview
    filelight
    filezilla
    obs-studio
    qbittorrent
    bitwarden

    # gaming
    steam
    lutris
    wine
    mangohud
    gamemode
    nvidia-settings
)

# install packages. --needed will not reinstall packages that are already up to date.
# pacman's output will tell which ones are being skipped.
sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"


# --- install paru ---
if ! command -v paru &> /dev/null; then
    echo "--- installing paru ---"
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
else
    echo "--- paru is already installed ---"
fi


# --- aur packages ---
echo "--- installing aur packages with paru ---"

aur_packages=(
    vesktop
    spotify
    music-presence-bin
    surfshark-client
)

paru -S --needed --noconfirm "${aur_packages[@]}"


# --- configure grub ---
echo "--- configuring grub for os-prober ---"
sudo sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg


# --- change default shell to zsh ---
echo "--- setting zsh as default shell ---"
# this will ask for your password
chsh -s "$(which zsh)"


# --- configure zsh ---
echo "--- configuring .zshrc ---"

# create .zshrc if it doesn't exist
touch ~/.zshrc

# append settings to .zshrc
cat <<EOF >> ~/.zshrc

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

if [[ $- == *i* ]]; then
  fastfetch
fi

alias fetch='fastfetch'
EOF


echo "--- all done. ---"
echo "run 'sudo shutdown now' to shutdown"
