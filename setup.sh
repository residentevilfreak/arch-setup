#!/bin/bash

# --- script configuration ---
#
# set -e: exit immediately if a command exits with a non-zero status.
# set -u: treat unset variables as an error when substituting.
# set -o pipefail: the return value of a pipeline is the status of the
# last command to exit with a non-zero status.
set -euo pipefail

# --- error handling ---
#
# this function is called by the trap on any error.
# it prints the error message and the line number where it occurred.
handle_error() {
    local exit_code=$?
    echo "❌ error: line $1: command failed with exit code $exit_code" >&2
    exit $exit_code
}

# trap any error signal and call the handle_error function
trap 'handle_error $LINENO' ERR

# --- logging functions ---
#
# provides formatted output for script progress.
log() {
    # blue color for info messages
    echo -e "\e[34m✅ [info]\e[0m $1"
}

warn() {
    # yellow color for warnings
    echo -e "\e[33m⚠️  [warn]\e[0m $1"
}

# --- pre-run checks ---
#
# ensures the script is executed with proper permissions.
check_privileges() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "❌ error: this script must be run with root privileges. please use 'sudo ./setup.sh'." >&2
        exit 1
    fi
    # SUDO_USER is set by sudo, and is the username of the user who invoked it.
    # this check ensures the script isn't run directly as the root user.
    if [[ -z "${SUDO_USER-}" ]]; then
        echo "❌ error: this script must be run via sudo, not directly as root." >&2
        echo "       please run as a regular user: 'sudo ./setup.sh'" >&2
        exit 1
    fi
    log "running with root privileges for user '$SUDO_USER'."
}

# --- installation functions ---

# 1. install packages from official repositories using pacman
install_pacman_packages() {
    log "starting pacman package installation..."
    
    # zsh-autosuggestions is added to fulfill a later configuration step.
    local pacman_packages=(
        # system essentials & drivers
        "amd-ucode" "base-devel" "btop" "dnsmasq" "iwd" "hostapd" "openssh" "pacman-contrib"
        "power-profiles-daemon" "reflector" "smartmontools" "os-prober" "git" "wget" "xdg-utils"
        # desktop environment (kde plasma) & utilities
        "plasma-meta" "ark" "dolphin" "kate" "kio-admin" "konsole" "packagekit-qt6"
        "noto-fonts" "noto-fonts-emoji"
        # shell & terminal tools
        "zsh" "zsh-autosuggestions" "fastfetch" "nano"
        # file management & compression
        "unrar"
        # applications
        "firefox" "mpv" "gwenview" "filelight" "filezilla" "obs-studio" "qbittorrent" "bitwarden"
        # gaming
        "steam" "lutris" "wine" "mangohud" "gamemode" "nvidia-settings"
    )

    # build a list of packages that are not already installed
    local packages_to_install=()
    for pkg in "${pacman_packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            packages_to_install+=("$pkg")
        else
            log "package '$pkg' is already installed. skipping."
        fi
    done

    if [ ${#packages_to_install[@]} -gt 0 ]; then
        log "installing ${#packages_to_install[@]} new packages: ${packages_to_install[*]}"
        pacman -S --noconfirm --needed "${packages_to_install[@]}"
    else
        log "all required pacman packages are already installed."
    fi
    log "pacman package installation finished."
}

# 2. install 'paru' aur helper if not present
install_paru() {
    log "checking for aur helper 'paru'..."
    if command -v paru &>/dev/null; then
        log "'paru' is already installed. skipping."
        return
    fi

    log "'paru' not found. installing from aur..."
    local build_dir
    build_dir=$(mktemp -d)
    log "cloning 'paru' into temporary directory: $build_dir"
    
    # run git clone and makepkg as the original user, not as root
    sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/paru.git "$build_dir/paru"
    
    pushd "$build_dir/paru" > /dev/null
    # makepkg must not be run as root
    sudo -u "$SUDO_USER" makepkg -si --noconfirm
    popd > /dev/null
    
    rm -rf "$build_dir"
    log "'paru' has been successfully installed."
}

# 3. install packages from the arch user repository (aur)
install_aur_packages() {
    log "starting aur package installation..."
    if ! command -v paru &>/dev/null; then
        echo "❌ error: 'paru' command not found. cannot install aur packages." >&2
        return 1
    fi
    
    local aur_packages=(
        "vesktop"
        "spotify"
        "music-presence-bin"
        "surfshark-client"
    )

    local packages_to_install=()
    for pkg in "${aur_packages[@]}"; do
        # use paru to check for aur packages
        if ! paru -Q "$pkg" &>/dev/null; then
            packages_to_install+=("$pkg")
        else
            log "aur package '$pkg' is already installed. skipping."
        fi
    done

    if [ ${#packages_to_install[@]} -gt 0 ];
    then
        log "installing ${#packages_to_install[@]} new aur packages: ${packages_to_install[*]}"
        # paru must be run as a normal user
        sudo -u "$SUDO_USER" paru -S --noconfirm --needed "${packages_to_install[@]}"
    else
        log "all required aur packages are already installed."
    fi
    log "aur package installation finished."
}

# --- configuration functions ---

# 4. configure grub to detect other operating systems
configure_grub() {
    log "configuring grub..."
    local grub_config="/etc/default/grub"

    if grep -q "^GRUB_DISABLE_OS_PROBER=false" "$grub_config"; then
        log "os-prober is already enabled in grub config. skipping."
    else
        log "enabling os-prober in grub config..."
        # this sed command finds the commented line and uncomments it. it's idempotent.
        sed -i 's/^#\(GRUB_DISABLE_OS_PROBER=false\)/\1/' "$grub_config"
    fi

    log "regenerating grub configuration..."
    grub-mkconfig -o /boot/grub/grub.cfg
    log "grub configuration complete."
}

# 5 & 6. change default shell to zsh and configure it
configure_zsh() {
    local user_name="$SUDO_USER"
    log "configuring zsh for user '$user_name'..."

    # change the default shell for the user who ran sudo
    local zsh_path
    zsh_path=$(which zsh)
    if [[ "$(getent passwd "$user_name" | cut -d: -f7)" == "$zsh_path" ]]; then
        log "default shell for '$user_name' is already zsh. skipping."
    else
        log "changing default shell for '$user_name' to zsh..."
        chsh -s "$zsh_path" "$user_name"
    fi

    # configure ~/.zshrc for the user
    local user_home
    user_home=$(getent passwd "$user_name" | cut -d: -f6)
    local zshrc_path="$user_home/.zshrc"

    log "ensuring '$zshrc_path' exists..."
    sudo -u "$user_name" touch "$zshrc_path"

    # define the configurations to add to .zshrc
    local zsh_configs=(
        '# enable zsh auto-suggestions'
        'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'
        '' # add a blank line for readability
        '# run fastfetch on startup of interactive shells'
        '[[ -o interactive ]] && fastfetch'
        ''
        '# alias for fastfetch'
        "alias fetch='fastfetch'"
    )

    for config_line in "${zsh_configs[@]}"; do
        # use grep with -f (fixed string) and -x (exact line match) to check for existence
        if grep -qFx "$config_line" "$zshrc_path"; then
            log "configuration line already in .zshrc: '$config_line'"
        else
            log "adding configuration to .zshrc: '$config_line'"
            echo "$config_line" >> "$zshrc_path"
        fi
    done

    # ensure the user owns their .zshrc file
    chown "$user_name":"$(id -gn "$user_name")" "$zshrc_path"
    log "zsh configuration for '$user_name' complete."
}

# --- main execution ---

main() {
    check_privileges
    install_pacman_packages
    install_paru
    install_aur_packages
    configure_grub
    configure_zsh
    log "🎉 arch linux post-install setup script completed successfully!"
}

# run the main function, passing all script arguments to it
main "$@"
