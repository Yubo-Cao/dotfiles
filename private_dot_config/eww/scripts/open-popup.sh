#!/usr/bin/env bash
set -euo pipefail

EWW_WINDOW_NAME="$1"

if [ -z "$EWW_WINDOW_NAME" ]; then
    echo "Usage: $0 <window name>"
    exit 1
fi

hyprctl keyword bind ",Escape,exec,eww close $EWW_WINDOW_NAME && hyprctl keyword unbind ,Escape"
eww open "$EWW_WINDOW_NAME"
