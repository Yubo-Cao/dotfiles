#!/usr/bin/bash

source "$CHEZMOI_SOURCE_DIR/common.sh"

set -euo pipefail

name="minimal"

install_theme() {
    info "Installing theme..."
    if sudo mkdir -p "/boot/grub/themes/$name"; then
        info "Created /boot/grub/themes/$name"
    else
        error "Failed to create /boot/grub/themes/$name"
    fi

    if sudo cp -r "$HOME/.root/grub/$name" "/boot/grub/themes/"; then
        info "Copied theme to /boot/grub/themes/$name"
    else
        error "Failed to copy theme to /boot/grub/themes/$name"
    fi
}

modify_grub() {
    info "Backing up /etc/default/grub to /etc/default/grub.bak"
    sudo cp /etc/default/grub{,.bak}

    info "Modifying /etc/default/grub..."
    modify_kv_config "GRUB_GFXMODE" "3072x1920x32,auto" "/etc/default/grub"
    modify_kv_config "GRUB_THEME" "/boot/grub/themes/$name/theme.txt" "/etc/default/grub"

    info "Saving grub config to /boot/grub/grub.cfg..."
    if sudo grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1; then
        info "Saved grub config to /boot/grub/grub.cfg"
    else
        error "Failed to save grub config to /boot/grub/grub.cfg"
    fi
}

if ! command -v grub-mkconfig &>/dev/null; then
    info "grub is not installed. Skipping..."
    exit 0
fi
install_theme
modify_grub
