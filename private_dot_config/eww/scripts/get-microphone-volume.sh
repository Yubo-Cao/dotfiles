#!/usr/bin/env bash

pamixer --default-source --get-volume

pactl subscribe | grep --line-buffered change | while read -r; do
    volume="$(pamixer --default-source --get-volume)"
    echo "$volume"
done
