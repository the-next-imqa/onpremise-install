#!/usr/bin/env bash

# Directories
export CONFIG_DIR="$HOME/.config"
export SYSTEMD_DIR="$CONFIG_DIR/systemd"
export USER_DIR="$SYSTEMD_DIR/user"
export SBIN_DIR="$HOME/.sbin"
export SCRIPT_PATH="$HOME/.scripts"

# Script paths
CONFIGURE_MYSQL_SCRIPT="$PWD/scriptV2/config_mysql.sh"
CONFIGURE_REDIS_SCRIPT="$PWD/scriptV2/config_redis.sh"
CONFIGURE_RABBITMQ_SCRIPT="$PWD/scriptV2/config_rabbitmq.sh"

# Function to confirm user input
confirm() {
  local yn
  while true; do
    read -p "$1 [y/N] : " yn
    yn=${yn:-n}
    case "$yn" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
    esac
  done
}

export -f confirm

# Function to create directory if it does not exist
create_dir() {
  if [ ! -d "$1" ]; then
    echo "Creating $1 directory..."
    mkdir -p "$1"
  else
    echo "$1 already exists. Skipping directory creation."
  fi
}

export -f create_dir

# Function to read user input with a default value
read_input() {
  local prompt=$1
  local default=$2
  local var
  read -p "$prompt (default $(tput bold)$default$(tput sgr0)): " var
  echo "${var:-$default}"
}

export -f read_input

# Function to handle service registration
handle_service() {
  local service_name=$1
  local config_script=$2
  local package_name=$3

  if confirm "Do you want to register $service_name service as non-sudo user? ($(whoami))"; then
    if [ $(rpm -qa | grep -c $package_name) -eq 0 ]; then
      echo "[IMQA] $service_name is not installed"
      echo "[IMQA] Please install $service_name first"
      echo "[IMQA] Aborting $service_name configuration"
    else
      echo "[IMQA] $service_name is installed"
      echo "[IMQA] Checking $service_name status"
      if [ $(systemctl --user is-active ${package_name}@imqa) == "active" ]; then
        echo "[IMQA] $service_name is running"
        echo "[IMQA] Stopping $service_name"
        systemctl --user stop ${package_name}@imqa
      else
        echo "[IMQA] $service_name is not running"
      fi
      sh $config_script
      echo "[IMQA] $service_name configuration done"
    fi
  else
    echo "[IMQA] Registering $service_name server daemon skipped..."
  fi
}

# Main script execution
if [ "$EUID" == 0 ]; then
  echo "Do not run as sudoer"
  exit
fi

create_dir "$SBIN_DIR"
create_dir "$CONFIG_DIR"
create_dir "$SYSTEMD_DIR"
create_dir "$USER_DIR"
create_dir "$SCRIPT_PATH"

# Register services
handle_service "MySQL" "$CONFIGURE_MYSQL_SCRIPT" "mysql"
handle_service "Redis" "$CONFIGURE_REDIS_SCRIPT" "redis"
handle_service "RabbitMQ" "$CONFIGURE_RABBITMQ_SCRIPT" "rabbitmq"

echo "Script execution completed."