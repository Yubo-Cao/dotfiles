#!/bin/bash

hyprctl workspaces -j | jq -Mc '[.[] | .name]'
socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - | while read -r line; do
    hyprctl workspaces -j | jq -Mc '[.[] | .name]'
done
