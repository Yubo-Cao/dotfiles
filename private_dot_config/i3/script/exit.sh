#!/usr/bin/env bash
i3-msg mode exit
i3-nagbar -t warning \
    -m "Are you sure you want to exit i3?" \
    -B "Yes, exit i3" "i3-msg exit" \
    -B "Cancel" "i3-msg mode default && killall i3-nagbar"
