#!/usr/bin/env bash

pamixer --get-mute

pactl subscribe | grep --line-buffered change | while read -r; do
    muted="$(pamixer --get-mute)"
    echo "$muted"
done
