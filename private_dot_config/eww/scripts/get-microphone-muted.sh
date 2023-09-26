#!/usr/bin/env bash

pamixer --default-source --get-mute

pactl subscribe | grep --line-buffered change | while read -r; do
    muted="$(pamixer --default-source --get-mute)"
    echo "$muted"
done
