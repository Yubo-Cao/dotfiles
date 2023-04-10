#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

info "Setting up i3"

install fonts \
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
    ttf-firacode-nerd \
    inter-font \
    ttf-material-design-icons-webfont \
    ttf-sarasa-gothic

install pipewire \
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


install i3 \
    i3-gaps-rounded-git \
    i3lock xss-lock

install "i3 utilies" \
    xdg-utils gnome-keyring \
    polkit-dump-agent xorg-xhost \
    xdg-desktop-portal xdg-desktop-portal-kde \
    xclip xsel xrandr \
    xborders-git \
    dunst

install "basic software" \
    gwenview \
    thunar \
    microsoft-edge-dev-bin \
    discord \
    gimp
