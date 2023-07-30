#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

# install common applications
install "Common applications" \
    bat \
    curl \
    exa \
    fd \
    fzf \
    git \
    htop \
    jq \
    neovim \
    ripgrep \
    unzip \
    wget \
    github-cli

# install desktop applications
install "Desktop applications" \
    discord \
    inkscape \
    kdenlive \
    libreoffice \
    mpv \
    obs-studio \
    pavucontrol \
    spotify \
    vlc \
    zathura \
    orchis-theme orchis-kde-theme-git \
    papirus-icon-theme \
    dbus
