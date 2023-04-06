#!/usr/bin/bash

# logging
error() {
  echo -e "\e[31m[Error] $1\e[0m"
}

warn() {
  echo -e "\e[33m[Warning] $1\e[0m"
}

info() {
  echo -e "\e[32m[Info] $1\e[0m"
}

# progress bar
progress_bar() {
  local percentage=$1
  local message=$2
  local bar_type=$3

  local width=$(($(tput cols) / 2))
  width=$((width > 80 ? width : 80))
  width=$((width - ${#message}))
  if [[ -n "$message" ]]; then width=$((width - 3)); fi
  ((width = width < 0 ? 0 : width))

  local progress=$((percentage * width / 100))
  local remaining=$((width - progress))
  local progress_bar=""
  progress_bar=$(printf "[%s%s]" "$(printf "#%.0s" $(seq 1 $progress))" "$(printf ' %.0s' $(seq 1 $remaining))")
  local final_message="${message:+[${message}] }${progress_bar} ${percentage}%"

  case "$bar_type" in
  info) printf "\r\e[32m%s\e[0m" "$final_message" ;;
  warn) printf "\r\e[33m%s\e[0m" "$final_message" ;;
  error) printf "\r\e[31m%s\e[0m" "$final_message" ;;
  *) printf "\r%s" "$final_message" ;;
  esac
}

# yay
install_yay() {
  if yay --version &>/dev/null; then
    warn "yay is already installed"
  else
    if sudo pacman -S --needed --noconfirm base-devel git >/dev/null 2>&1; then
      info "Dependencies installed successfully"
    else
      error "Failed to install dependencies"
    fi
    temp=$(mktemp -d)
    info "Cloning yay..."
    git clone https://aur.archlinux.org/yay-bin.git "$temp/yay-bin" >/dev/null 2>&1
    cd "$temp/yay-bin" || exit
    info "Building yay..."
    if makepkg -si --noconfirm >/dev/null 2>&1; then
      info "yay installed successfully"
    else
      error "Failed to install yay"
    fi
    cd ~ || exit
    rm -rf "$temp"
  fi
}

# aur
install() {
  if ! command -v yay &>/dev/null; then
    info "yay is not installed. Installing yay..."
    install_yay
  fi

  local title=$1
  shift
  local packages=("$@")
  local total_packages=${#packages[@]}
  local progress=0
  local success=()
  local failure=()

  info "Installing $title..."

  for package in "${packages[@]}"; do
    ((progress++))
    local percentage=$((progress * 100 / total_packages))
    progress_bar "$percentage" "$package"
    if yay -S --noconfirm --needed "$package" >/dev/null 2>&1; then
      progress_bar "$percentage" "$package" "info"
      sleep 0.05
      success+=("✅ $package")
    else
      progress_bar "$percentage" "$package" "error"
      sleep 0.05
      failure+=("❌ $package")
    fi
  done

  echo

  if [ ${#success[@]} -gt 0 ]; then
    printf '%s\n' "${success[@]}"
  fi

  if [ ${#failure[@]} -gt 0 ]; then
    printf '%s\n' "${failure[@]}"
  fi
}

# modify kv conig
modify_kv_config() {
  local key=$1
  local value=$2
  local file=$3

  if grep -q "$key" "$file"; then
    if grep "^$key" "$file" | grep -q "$value"; then
      info "$key is already set to $value in $file"
      return
    else
      info "Modifying $key in $file..."
      sudo sed -i "s|^\(#[ ]*\)\?$key.*$|$key=\"$value\"|" "$file"
    fi
  else
    info "Adding $key to $file..."
    echo "$key=$value" | sudo tee -a "$file" >/dev/null
  fi
}
