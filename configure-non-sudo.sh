#!/usr/bin/env bash

export CONFIG_DIR="$HOME/.config"
export SYSTEMD_DIR="$CONFIG_DIR/systemd"
export USER_DIR="$SYSTEMD_DIR/user"
export SBIN_DIR="$HOME/.sbin"
export SCRIPT_PATH="$HOME/.scripts"

CONFIGURE_MYSQL_SCRIPT="$PWD/scriptV2/config_mysql.sh"
CONFIGURE_REDIS_SCRIPT="$PWD/scriptV2/config_redis.sh"

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

export -f confirm

create_dir() {
  if [ ! -d "$1" ]; then
    echo "Creating $1 directory..."
    mkdir -p "$1"
  else
    echo "$1 already exists. Skipping directory creation."
  fi
}

export -f create_dir

read_input() {
  local prompt=$1
  local default=$2
  local var
  read -p "$prompt (default $(tput bold)$default$(tput sgr0)): " var
  echo "${var:-$default}"
}

export -f read_input

if [ "$EUID" == 0 ]; then
  echo "Do not run as sudoer"
  exit
fi

create_dir "$SBIN_DIR"
create_dir "$CONFIG_DIR"
create_dir "$SYSTEMD_DIR"
create_dir "$USER_DIR"
create_dir "$SCRIPT_PATH"

# MySQL
if confirm "Do you want to register MySQL service as non-sudo user? ($(whoami))"; then
  # Check if mysql is installed
  if [ $(rpm -qa | grep -c mysql) -eq 0 ]; then
    echo "[IMQA] MySQL is not installed"
    echo "[IMQA] Please install MySQL first"
    echo "[IMQA] Aborting MySQL configuration"
  else
    echo "[IMQA] MySQL is installed"
    echo "[IMQA] Checking MySQL status"
    # Check if mysql is running
    if [ $(systemctl --user is-active mysqld@imqa) == "active" ]; then
      echo "[IMQA] MySQL is running"
      echo "[IMQA] Stopping MySQL"
      systemctl --user stop mysqld@imqa
    else
      echo "[IMQA] MySQL is not running"
    fi
    sh $CONFIGURE_MYSQL_SCRIPT
    echo "[IMQA] MySQL configuration done"
  fi
else
  echo "[IMQA] Registering MySQL server daemon skipped..."
fi

# Redis
if confirm "Do you want to register Redis service as non-root user? ($(whoami))"; then
  # Check if redis is installed
  if [ $(rpm -qa | grep -c redis) -eq 0 ]; then
    echo "[IMQA] Redis is not installed"
    echo "[IMQA] Please install Redis first"
    echo "[IMQA] Aborting Redis configuration"
  else
    echo "[IMQA] Redis is installed"
    echo "[IMQA] Checking Redis status"
    # Check if redis is running
    if [ $(systemctl --user is-active redis@imqa) == "active" ]; then
      echo "[IMQA] Redis is running"
      echo "[IMQA] Stopping Redis service"
      systemctl --user stop redis@imqa
    else
      echo "[IMQA] Redis is not running"
    fi
    sh $CONFIGURE_REDIS_SCRIPT
    echo "[IMQA] Redis configuration done"
  fi
else
  echo "[IMQA] Registering Redis server daemon skipped..."
fi

echo "Script execution completed."
