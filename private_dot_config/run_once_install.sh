#!/usr/bin/bash
source "$CHEZMOI_SOURCE_DIR/common.sh"

info "Setting up theme"
install "Theme" \
	papirus-icon-theme \
	phinger-cursors \
	sassc gtk-engine-murine gnome-themes-extra

install "Theme Manager" \
	nwg-look-bin \
	qt5ct qt6ct kvantum kvantum-theme-orchis-git

info "Setting up Orchis Theme"
temp_dir="/tmp/Orchis-theme"

cleanup() {
	info "Cleaning up Orchis Theme"
	rm -rf "$temp_dir"
}

trap cleanup EXIT

if [ ! -d "$temp_dir" ]; then
	info "Fetching vinceliuice/Orchis-theme"
	git clone https://github.com/vinceliuice/Orchis-theme "$temp_dir"
else
	info "Orchis-theme directory already exists"
	exit 1
fi

cd "$temp_dir"
./install.sh -t default -c light -s standard -l --round 8px
trap - EXIT

info "Orchis Theme setup completed successfully"
