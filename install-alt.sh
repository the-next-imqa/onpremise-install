#!/usr/bin/env bash

# Constants
REPO_FILE="/etc/yum.repos.d/offline-imqa.repo"
REPO_NAME="offline-imqa"
REPO_URL="file://$REPO_FOLDER/repo"

# Function to confirm user input
confirm() {
  local yn
  while true; do
    read -p "$1 [y/N] : " yn
    yn=${yn:-n}
    case "$yn" in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

# Check if the script is run as root
check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
  fi
}

# Setup the repository
setup_repo() {
  echo "[IMQA] Setting up repository..."
  read -p "Enter the full path of the repo folder: " REPO_FOLDER

  if [ ! -d "$REPO_FOLDER" ]; then
    echo "[IMQA] Creating repo folder at $REPO_FOLDER..."
    mkdir -p "$REPO_FOLDER" || { echo "Failed to create repo folder"; exit 1; }
  fi

  echo "[IMQA] Extracting packages..."
  rpm -i tar-1.30-9.el8.x86_64.rpm || { echo "Failed to install tar"; exit 1; }
  read -p "Enter the full path of the tar file (gz): " TAR_FILE
  if [ -f "$TAR_FILE" ]; then
    tar -zxvf "$TAR_FILE" -C "$REPO_FOLDER" || { echo "Failed to extract tar file"; exit 1; }
  else
    echo "$TAR_FILE does not exist"
    exit 1
  fi

  echo "[IMQA] Creating repo configuration..."
  sudo rm -rf "$REPO_FILE"
  echo -e "[$REPO_NAME]\nname=RHEL8-IMQA-Repository\nbaseurl=$REPO_URL\nenabled=1\ngpgcheck=0\nmodule_hotfixes=1" | sudo tee "$REPO_FILE" > /dev/null || { echo "Failed to create repo file"; exit 1; }
}

# Install a single package
install_package() {
  local package_name=$1
  echo "[IMQA] Installing $package_name..."
  yum --disablerepo=\* --enablerepo=$REPO_NAME install "$package_name" -y || { echo "Failed to install $package_name"; exit 1; }
}

# Install multiple packages
install_multiple_packages() {
  local packages=("$@")
  for package in "${packages[@]}"; do
    install_package "$package"
  done
}

# Install optional packages with confirmation
install_optional_packages() {
  local packages=("$@")
  local prompt_message=${packages[-1]}
  unset 'packages[-1]'
  if confirm "$prompt_message"; then
    install_multiple_packages "${packages[@]}"
  fi
}

# Install Docker packages
install_docker() {
  if confirm "Do you want to install docker-ce?"; then
    install_multiple_packages "docker-ce" "docker-ce-cli" "containerd.io" "docker-buildx-plugin" "docker-compose-plugin"
  fi
}

# Install RabbitMQ packages
install_rabbitmq() {
  if confirm "Do you want to install rabbitmq?"; then
    install_multiple_packages "socat" "logrotate" "erlang" "rabbitmq-server"
  fi
}

# Install MySQL packages
install_mysql() {
  if confirm "Do you want to install mysql-5.7.44?"; then
    install_multiple_packages "mysql-community-server" "mysql-community-client"
  fi
}

# Main installation function
main() {
  check_root

  if confirm "[IMQA] Setup Repository"; then
    setup_repo
  else
    echo "[IMQA] Skipping Repository Setup"
  fi

  if confirm "[IMQA] Install Packages"; then
    install_package "git"

    install_optional_packages "nginx" "Do you want to install nginx?"
    install_optional_packages "haproxy" "Do you want to install haproxy?"
    install_optional_packages "proxysql" "Do you want to install proxysql?"
    install_optional_packages "redis" "Do you want to install redis?"
    install_rabbitmq
    install_optional_packages "java-11-openjdk-devel-11.0.3.7-2.el8_0" "Do you want to install JDK 11.0.3?"
    install_docker
    install_mysql

    # Uncomment and adjust the following lines to handle NVM installation
    # if confirm "Do you want to install NVM with Node12 & Node18?"; then
    #   install_nvm
    # fi

  else
    echo "[IMQA] Skipping Package Installation"
    exit 0
  fi

  echo "[IMQA] Installation Done"
  echo "Please restart your terminal to apply changes"
}

main