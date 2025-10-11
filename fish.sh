#!/bin/bash
#
# fish.sh - a script to automate post-installation tasks for my arch linux installs.
# this script installs essential packages, an aur helper (paru), aur packages,
# and configures the fish shell.
#

# --- color codes for output ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # no color

# --- function to print styled messages ---
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# --- check if running as root ---
if [[ $EUID -eq 0 ]]; then
   warning "this script should not be run as root. it will prompt for sudo password when needed." 
   exit 1
fi

# --- package lists ---
PACMAN_PACKAGES=(
    # system essentials & drivers
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

    # desktop environment (kde plasma) & utilities
    plasma-meta
    ark
    dolphin
    kate
    kio-admin
    konsole
    packagekit-qt6
    noto-fonts
    noto-fonts-emoji
    
    # shell & terminal tools
    fish
    fastfetch
    nano

    # file management & compression
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

AUR_PACKAGES=(
    vesktop
    spotify
    music-presence-bin
    surfshark-client
)

# --- function to install packages from official repositories ---
install_pacman_packages() {
    # check which packages are already installed
    local already_installed=()
    for pkg in "${PACMAN_PACKAGES[@]}"; do
        if pacman -Q "$pkg" &> /dev/null; then
            already_installed+=("$pkg")
        fi
    done

    # if any packages were found, print them to the console
    if [ ${#already_installed[@]} -gt 0 ]; then
        log "the following pacman packages are already installed:"
        for pkg in "${already_installed[@]}"; do
            echo "  - $pkg"
        done
    fi
    
    log "installing packages from official repositories..."
    sudo pacman -Syu --noconfirm --needed "${PACMAN_PACKAGES[@]}"
    success "pacman packages installed."
}

# --- function to install paru (aur helper) ---
install_paru() {
    if ! command -v paru &> /dev/null; then
        log "paru not found. installing..."
        cd /tmp
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin
        makepkg -si --noconfirm
        cd ..
        rm -rf paru-bin
        success "paru has been installed."
    else
        log "paru is already installed."
    fi
}

# --- function to install packages from aur ---
install_aur_packages() {
    log "installing aur packages..."
    paru -S --noconfirm --needed "${AUR_PACKAGES[@]}"
    success "aur packages installed."
}

# --- function to configure grub ---
configure_grub() {
    log "configuring grub..."
    sudo sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    success "grub configuration updated."
}

# --- function to set up fish ---
configure_fish() {
    log "configuring fish as the default shell..."

    # change shell for the current user to fish
    if [ "$SHELL" != "$(which fish)" ]; then
        chsh -s "$(which fish)"
        log "default shell changed to fish."
    else
        log "fish is already the default shell."
    fi

    # create fish config directory if it doesn't exist
    log "creating fish configuration directory..."
    mkdir -p ~/.config/fish

    # create or append to config.fish with the specified settings
    log "adding custom configuration to ~/.config/fish/config.fish..."
    cat <<'EOF' >> ~/.config/fish/config.fish

# --- custom configuration added by script ---

# 1. run fastfetch if the shell is interactive
if status is-interactive
    fastfetch
end

# 2. turn off the fish greeting
set -U fish_greeting

# 3. add the alias 'fetch' for 'fastfetch'
alias fetch="fastfetch"

# --- end of custom configuration ---
EOF

    success "fish configured."
}


# --- main execution ---
main() {
    log "starting arch linux post-install setup..."

    install_pacman_packages
    install_paru
    install_aur_packages
    configure_grub
    configure_fish

    echo -e "\n\n"
    success "all tasks completed!"
    log "please log out and log back in for all changes to take effect."
    log "a system reboot is recommended."
}

# --- run the script ---
main
