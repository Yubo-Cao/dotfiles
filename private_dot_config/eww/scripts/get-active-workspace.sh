#!/usr/bin/env bash

hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.name'

socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - |
    stdbuf -o0 awk -F '>>|,' -e '/^workspace>>/ {print $2}' -e '/^focusedmon>>/ {print $3}'
