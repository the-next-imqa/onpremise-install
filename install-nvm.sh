#!/usr/bin/env bash

if [ ! "$EUID" -ne 0 ]
  then echo "Do not run as sudoer"
  exit
fi

confirm() {
  local yn
  while true; do
    read -p "$1 [y/N] : " yn
    yn=${yn:-n}
    case "$yn" in
      [Yy]* ) echo "1"; return;;
      [Nn]* ) echo "0"; return;;
    esac
  done
}

echo "[IMQA] Installing NVM with Node12 & Node18"
if [ $(confirm "Do you want to install NVM with Node12 & Node18?") -eq "1" ]; then
  NVM_PACKAGE_FILE=nvm-packed-12-18.tar.xz
  BASHRC=$HOME/.bashrc
  NVM_EXPORT='export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
  if [ ! -d "$HOME/.nvm" ]; then
    if [ -f "$NVM_PACKAGE_FILE" ]; then
      echo "Installing nvm from $NVM_PACKAGE_FILE"
      tar -xJvf "$NVM_PACKAGE_FILE" -C $HOME
      sh $HOME/.nvm/install.sh
    else
      echo "$NVM_PACKAGE_FILE is not exist in $HOME"
      exit 1
    fi
  else
    echo "[IMQA] NVM already installed"
  fi
  TEMP_FILE=$(mktemp)
  echo "$NVM_EXPORT" > "$TEMP_FILE"
  
  if ! grep -F "$(cat "$TEMP_FILE")" "$BASHRC" > /dev/null; then
    cat "$TEMP_FILE" >> "$BASHRC"
  fi

  rm -f "$TEMP_FILE"
  echo "All setup"
  echo "Reload bash profile 'source ~/.bashrc'"
fi