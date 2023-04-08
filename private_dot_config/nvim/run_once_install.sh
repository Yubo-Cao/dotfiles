#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

install "Neovim" \
    neovim \
    neovide

# LSP
install "LSP" \
    nodejs rust_analyzer
info "Install TS language server"
sudo npm install -g typescript typescript-language-server
info "Install Python language server"
sudo npm install -g pyright
info "Install Bash language server"
sudo npm install -g bash-language-server
