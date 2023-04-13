#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

install "Fcitx5" \
    fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt \
    fcitx5-chinese-addons fcitx5-lua \
    fcitx5-nord
