#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

install "latexindent dependency" \
    perl-yaml-tiny perl-file-homedir
