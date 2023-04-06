#!/usr/bin/bash

source "$CHEZMOI_SOURCE_DIR/common.sh"

info "Install matter dependencies"
install "Matter" \
    inkscape \
    grub-customizer

info "Install matter"
sudo python "$HOME/.root/grub/matter/matter.py" \
        --fontname 'Inter Regular' \
        --fontfile /usr/share/fonts/inter/Inter-Regular.ttf \
        --icons arch _ _ _ _ _ microsoft-windows folder \
        --highlight 'bfdbfe' --foreground '1e293b' --background 'f8fafc'
        # blue-200 slate-800 slate-50
