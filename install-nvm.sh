#!/usr/bin/env bash

NVM_PACKAGE_FILE=nvm-packed-12-18.tar.xz

if [ -f "$NVM_PACKAGE_FILE" ]; then
  echo "Installing nvm from $NVM_PACKAGE_FILE"
  tar -xJvf "$NVM_PACKAGE_FILE" -C $HOME
  sh $HOME/.nvm/install.sh
  sh $HOME/.nvm/set-env.sh
  echo "All setup"
  echo "Reload bash profile `source ~/.bashrc`"
else
  echo "$NVM_PACKAGE_FILE is not exist in $HOME"
  exit 1
fi