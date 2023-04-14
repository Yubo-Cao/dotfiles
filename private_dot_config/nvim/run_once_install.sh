#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

install "Neovim" \
    neovim \
    neovide
# Packer
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim
# LSP
install "LSP" \
    nodejs npm rust_analyzer
info "Install TS language server"
sudo npm install -g typescript typescript-language-server
info "Install Python language server"
sudo npm install -g pyright
info "Install Bash language server"
sudo npm install -g bash-language-server
info "Install Grammarly language server"
sudo npm install -g grammarly-languageserver

# VimTeX
install "Zathura" \
    zathura zathura-pdf-poppler
