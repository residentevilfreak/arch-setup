#!/usr/bin/env bash

#
# arch linux post-install setup script
#
# this script automates the setup of a fresh arch linux installation
# according to my preferences.
#

# exit immediately if a command fails
set -e

# --- PACKAGE LISTS ---
# add or remove packages here as you see fit.

# packages from official arch repositories
PACMAN_PACKAGES=(
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
AUR_PACKAGES=(
    vesktop
    spotify
    music-presence-bin
    surfshark-client
)


# --- SCRIPT EXECUTION ---

echo ">>> starting arch linux post-install setup..."

# step 1: install pacman packages
echo ">>> updating system and installing packages from official repositories..."
sudo pacman -Syu --needed --noconfirm "${PACMAN_PACKAGES[@]}"


# step 2: install aur helper (paru)
if ! command -v paru &> /dev/null; then
    echo ">>> installing aur helper 'paru'..."
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
    rm -rf "$temp_dir"
else
    echo ">>> aur helper 'paru' is already installed."
fi


# step 3: install aur packages
echo ">>> installing packages from the aur..."
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"


# step 4: configure grub
echo ">>> configuring grub to enable os-prober..."
sudo sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg


# step 5: change default shell to fish
if [ "$SHELL" != "/usr/bin/fish" ]; then
    echo ">>> changing default shell to fish for user $USER..."
    chsh -s "$(which fish)"
    echo "shell changed to fish. please log out and back in for it to take effect."
else
    echo ">>> default shell is already fish."
fi


# step 6: configure fish shell
echo ">>> creating fish configuration..."
mkdir -p ~/.config/fish
cat <<'EOF' > ~/.config/fish/config.fish
# run fastfetch on startup if the shell is interactive
if status is-interactive
    fastfetch
end

# disable fish greeting
set fish_greeting

# create aliases
alias fetch="fastfetch"
EOF

echo "------------------------------------------"
echo ">>> setup complete! <<<"
echo "reboot to apply all changes."
echo "run sudo shutdown now to shutdown"
echo "------------------------------------------"
