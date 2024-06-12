#!/usr/bin/env bash

read_input() {
  local prompt=$1
  local default=$2
  local var
  read -p "$prompt (default $default): " var
  echo "${var:-$default}"
}

export -f read_input

sh b.sh