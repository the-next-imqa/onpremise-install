#!/usr/bin/env bash

read_input() {
  local prompt=$1
  local default=$2
  local var
  read -p "$prompt (default $default): " var
  echo "${var:-$default}"
}

export -f read_input

confirm() {
  local yn
  while true; do
    read -p "$1 [y/N] : " yn
    yn=${yn:-n}
    case "$yn" in
    [Yy]*) 
      return 0
      ;;
    [Nn]*)
      return 1
      ;;
    esac
  done
}

# Example usage
if confirm "Do you want to continue?"; then
  echo "User confirmed."
else
  echo "User did not confirm."
fi

sh b.sh