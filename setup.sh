#!/bin/bash

exec < /dev/tty

echo "=== arch linux setup script ==="

PACMAN_PKGS=(
  amd-ucode btop dnsmasq iwd hostapd openssh pacman-contrib power-profiles-daemon 
  reflector smartmontools os-prober git sddm wget xdg-utils plasma-meta 
  ark dolphin kate kio-admin konsole packagekit-qt6 noto-fonts
  noto-fonts-emoji fastfetch nano fish unrar firefox mpv gparted gwenview 
  filelight filezilla obs-studio qbittorrent bitwarden steam lutris
  wine mangohud gamemode nvidia-settings
)

sudo pacman -S --needed "${PACMAN_PKGS[@]}"

git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si 
cd -
rm -rf /tmp/paru

paru -S vesktop spotify music-presence-bin surfshark-client

sudo sed -i -e 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' -e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=-1/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

chsh -s "$(which fish)"

mkdir -p ~/.config/fish
cat > ~/.config/fish/config.fish << 'EOF'
if status is-interactive
    fastfetch
end

set fish_greeting

alias fetch='fastfetch'
EOF

sudo systemctl enable sddm.service
sudo systemctl enable power-profiles-daemon.service
sudo systemctl enable iwd.service

echo "=== setup complete! ==="
