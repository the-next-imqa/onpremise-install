#!/usr/bin/env bash

confirm() {
  local yn
  while true; do
    read -p "$1 [y/N] : " yn
    yn=${yn:-n}
    case "$yn" in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
    esac
  done
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
  fi
}

setup_repo() {
  echo "[IMQA] Setup Repository"
  read -p "Enter the full path of the repo folder: " REPO_FOLDER
  echo "[IMQA] Check the repo folder..."
  [ ! -d "$REPO_FOLDER" ] && mkdir -p "$REPO_FOLDER"

  echo "[IMQA] Extracting packages"
  rpm -i tar-1.30-9.el8.x86_64.rpm
  read -p "Enter the full path of the tar file (gz): " TAR_FILE
  if [ -f "$TAR_FILE" ]; then
    tar -zxvf "$TAR_FILE" -C "$REPO_FOLDER"
  else
    echo "$TAR_FILE does not exist"
    exit 1
  fi

  sudo rm -rf /etc/yum.repos.d/offline-imqa.repo

  echo "[IMQA] Creating repo"
  echo -e "[offline-imqa]\nname=RHEL8-IMQA-Repository\nbaseurl=file://$REPO_FOLDER/repo\nenabled=1\ngpgcheck=0\nmodule_hotfixes=1" | tee /etc/yum.repos.d/offline-imqa.repo > /dev/null
}

install_package() {
  local package_name=$1
  echo "[IMQA] Installing $package_name"
  yum --disablerepo=\* --enablerepo=offline-imqa install "$package_name" -y
}

install_optional_package() {
  local package_name=$1
  if confirm "Do you want to install $package_name?"; then
    install_package "$package_name"
  fi
}

install_nvm() {
  local nvm_package_file=nvm-packed-12-18.tar.xz
  local bashrc=$HOME/.bashrc
  local nvm_export='export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
  
  if [ ! -d "$HOME/.nvm" ]; then
    if [ -f "$nvm_package_file" ]; then
      echo "Installing nvm from $nvm_package_file"
      tar -xJvf "$nvm_package_file" -C "$HOME"
      sh "$HOME/.nvm/install.sh"
    else
      echo "$nvm_package_file does not exist in $HOME"
      exit 1
    fi
  else
    echo "[IMQA] NVM already installed"
  fi
  
  if ! grep -F "$nvm_export" "$bashrc" > /dev/null; then
    echo "$nvm_export" >> "$bashrc"
  fi
  
  echo "All setup"
  echo "Reload bash profile 'source ~/.bashrc'"
}

main() {
  check_root

  if confirm "[IMQA] Installation Repository"; then
    setup_repo
  else
    echo "[IMQA] Skipping Repository Setup"
  fi

  if confirm "[IMQA] Installation Packages"; then
    echo "[IMQA] Installing Common Dependencies"
    install_package "git"

    install_optional_package "nginx"
    install_optional_package "haproxy"
    install_optional_package "proxysql"
    install_optional_package "redis"
    install_optional_package "socat logrotate"
    install_optional_package "erlang rabbitmq-server"
    install_optional_package "java-11-openjdk-devel-11.0.3.7-2.el8_0"
    install_optional_package "docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
    install_optional_package "mysql-community-server mysql-community-client"

    if confirm "Do you want to install NVM with Node12 & Node18?"; then
      install_nvm
    fi
  else
    echo "[IMQA] Skipping Installation"
  fi

  echo "[IMQA] Installation Done"
  echo "Please restart your terminal to apply changes"
}

main