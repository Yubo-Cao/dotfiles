#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

install_texlive() {
    if command -v tlmgr >/dev/null; then
        info "TeX Live is already installed"
        return
    fi

    info "Installing TeX Live"
    TEMP_DIRECTORY=$(mktemp -d)

    # ensure that the temporary directory is removed on exit
    trap 'rm -rf $TEMP_DIRECTORY' EXIT
    trap 'rm -rf $TEMP_DIRECTORY' SIGINT

    cd "$TEMP_DIRECTORY" || exit 1
    wget "https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz" --output-document "install-tl-unx.tar.gz"
    tar -xf install-tl-unx.tar.gz || exit 1

    # try to cd to install-tl-*
    for d in install-tl-*; do
        if [ -d "$d" ]; then
            cd "$d" || exit 1
            break
        fi
    done

    info "Running TeX Live installer"
    if pacman -Qq perl >/dev/null; then
        info "perl is already installed"
    else
        info "Installing perl"
        sudo pacman -S --noconfirm perl >/dev/null
    fi
    sudo perl install-tl --paper letter \
        --no-src-install \
        --no-doc-install \
        --no-interaction || exit 1
    info "TeX Live installed"
    rm -rf "$TEMP_DIRECTORY"
    # environment variables are handled by Fish
}

install_texlive
