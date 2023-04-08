#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

install_texlive() {
    if command -v tlmgr > /dev/null; then
        info "TeX Live is already installed"
        return
    fi

    info "Installing TeX Live"
    tmp=$(mktemp -d)
    trap "rm -rf $tmp" EXIT
    cd "$tmp"
    curl "https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz" --output "install-tl-unx.tar.gz"
    zcat < "install-tl-unx.tar.gz" | tar -xvf -
    cd install-tl-*
    info "Running TeX Live installer"
    if pacman -Qq perl > /dev/null; then
        info "perl is already installed"
    else
        info "Installing perl"
        sudo pacman -S --noconfirm perl > /dev/null
    fi
    sudo perl install-tl --paper letter \
        --no-src-install \
        --no-doc-install \
        --no-interaction > /dev/null
    info "TeX Live installed" 
    rm -rf "$tmp"
    # environment variables are handled by Fish
}

install_texlive
