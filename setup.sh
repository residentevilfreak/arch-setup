#!/bin/bash
set -e

echo "=== arch linux setup script ==="

# pacman packages
PACMAN_PKGS=(
  amd-ucode base-devel btop dnsmasq iwd hostapd openssh pacman-contrib
  power-profiles-daemon reflector smartmontools os-prober git wget xdg-utils
  plasma-meta ark dolphin kate kio-admin konsole packagekit-qt6 noto-fonts
  noto-fonts-emoji fastfetch nano fish unrar firefox mpv
  gwenview filelight filezilla obs-studio qbittorrent bitwarden steam lutris
  wine mangohud gamemode nvidia-settings
)

# check which packages are already installed
echo -e "\n=== checking installed packages ==="
for pkg in "${PACMAN_PKGS[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    echo "✓ $pkg (already installed)"
  fi
done

# install pacman packages
echo -e "\n=== installing pacman packages ==="
sudo pacman -S --noconfirm "${PACMAN_PKGS[@]}"

# install paru
if ! command -v paru &>/dev/null; then
  echo -e "\n=== installing paru ==="
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  cd /tmp/paru
  makepkg -si --noconfirm
  cd -
  rm -rf /tmp/paru
fi

# install aur packages with paru
echo -e "\n=== installing aur packages ==="
paru -S --noconfirm vesktop spotify music-presence-bin surfshark-client

# configure grub
echo -e "\n=== configuring grub ==="
sudo sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# set fish as shell
echo -e "\n=== setting fish as default shell ==="
chsh -s "$(which fish)"

# configure fish
echo -e "\n=== configuring fish ==="
cat > ~/.config/fish/config.fish << 'EOF'
if status is-interactive
    fastfetch
end

alias fetch='fastfetch'

set fish_greeting
EOF

echo -e "\n=== setup complete! ==="
