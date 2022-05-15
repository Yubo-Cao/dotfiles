#!/usr/bin/zsh
git clone https://aur.archlinux.org/yay.git &> /dev/null
cd ./yay
makepkg -si --needed --noconfirm &> /dev/null
