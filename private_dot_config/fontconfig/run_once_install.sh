#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

info "Setting up fonts"

install fonts \
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
    ttf-cascadia-code-nerd \
    inter-font \
    ttf-sarasa-gothic \
    ttf-material-design-iconic-font
