#!/usr/bin/env bash

pamixer --get-volume

pactl subscribe | grep --line-buffered change | while read -r; do
    volume="$(pamixer --get-volume)"
    echo "$volume"
done
