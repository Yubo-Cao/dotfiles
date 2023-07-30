#!/usr/bin/bash

source "$CHEZMOI_SOURCE_DIR/common.sh"

install "Display fonts" \
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
    inter-font \
    ttf-material-design-icons-webfont

install "Pipewire Audio Server" \
    pipewire wireplumber pipewire-audio pipewire-jack pipewire-alsa pipewire-pulse

if [ "$(id -u)" -ne 0 ]; then
    if systemctl --user enable --now pipewire-pulse &&
        systemctl --user enable --now pipewire; then
        info "Pipewire enabled"
    else
        error "Failed to enable Pipewire"
    fi
else
    warn "Skipping as user is root"
fi

install "Hypr" \
    hyprland

install "Hypr utilies" \
    grim slurp \
    wl-clipboard \
    xdg-utils gnome-keyring xorg-xwayland \
    autotiling-rs \
    polkit-dump-agent-git xorg-xhost \
    xdg-desktop-portal-hyprland \
    hyprpaper swayidle swaylock-effects-git
