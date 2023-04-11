#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

info "Setting up fonts"

install fonts \
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
    ttf-firacode-nerd \
    inter-font \
    ttf-material-design-icons-webfont \
    ttf-sarasa-gothic
