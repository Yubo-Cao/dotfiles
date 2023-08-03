#!/usr/bin/env bash

hyprctl activewindow -j | jq -Mcr ".title"
socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - |
    stdbuf -o0 awk -F '>>|,' -e '/^activewindow>>/ {print $3}' -e '/^focusedmon>>/ {print $3}'
