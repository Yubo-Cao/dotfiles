#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

install "Display fonts" \
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
    ttf-firacode-nerd \
    inter-font \
    ttf-material-design-icons-webfont

install "Pipewire Audio Server" \
    pipewire wireplumber pipewire-audio pipewire-jack pipewire-alsa pipewire-pulse
if [ $(id -u) -ne 0 ]; then
    systemctl --user enable --now pipewire-pulse && \
        systemctl --user enable --now pipewire && \
        info "Pipewire enabled" || \
        error "failed to enable Pipewire"
else
    warn "Skipping as user is root"
fi

install "Sway" \
    sway swaylock swayidle swaybg

sudo systemctl enable --now seatd && \
    info "seatd enabled" || \
    error "failed to enable seatd"
sudo usermod -aG seat "$(whoami)" \
    && info "Added user to seat group" || \
    error "failed to add user to seat group"

install "Sway utilies" \
    grim slurp \
    wl-clipboard \
    xdg-utils gnome-keyring xorg-xwayland \
    autotiling-rs \
    polkit-dump-agent xorg-xhost \
    xdg-desktop-portal xdg-desktop-portal-kde xdg-desktop-portal-wlr