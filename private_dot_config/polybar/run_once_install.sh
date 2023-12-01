#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

install Polybar \
    polybar mpd light

install "Python scripts" \
    python-jinja
