#!/usr/bin/bash
xrandr --output eDP-1 --dpi 220
for (( i=1; i <= 2; i++ ))
do
    xrandr --output HDMI-1 --dpi 96 --scale 1x1 --right-of eDP-1
    sleep 0.05
    xrandr --output HDMI-1 --dpi 96 --scale 1.5x1.5 --right-of eDP-1
done