#!/usr/bin/env bash

CONFIG_DIR="$HOME/.config"
SYSTEMD_DIR="$CONFIG_DIR/systemd"
USER_DIR="$SYSTEMD_DIR/user"
SBIN_DIR="$HOME/.sbin"
MYSQL_BASE_PATH="$HOME/mysql"
MYSQL_CONFIG_FILE="my.cnf"
MYSQL_CONFIG_FILE_PATH="$PWD/template/mysql/$MYSQL_CONFIG_FILE"
MYSQL_PRE_SCRIPT_PATH="$HOME/.scripts"
MYSQL_PRE_SCRIPT_FILE="mysqld_pre_systemd"
MYSQL_PRE_SCRIPT_FILE_PATH="$PWD/template/mysql/$MYSQL_PRE_SCRIPT_FILE"
MYSQL_SERVICE_FILE="mysqld@imqa.service"
MYSQL_SERVICE_FILE_PATH="$PWD/template/mysql/$MYSQL_SERVICE_FILE"
MYSQL_SERVICE_ENV_FILE="mysqld@imqa"
MYSQL_SERVICE_ENV_FILE_PATH="$PWD/template/mysql/$MYSQL_SERVICE_ENV_FILE"

confirm() {
  local yn
  while true; do
    read -p "$1 [y/N] : " yn
    yn=${yn:-n}
    case "$yn" in
    [Yy]*)
      echo "1"
      return
      ;;
    [Nn]*)
      echo "0"
      return
      ;;
    esac
  done
}

if [ "$EUID" == 0 ]; then
  echo "Do not run as sudoer"
  exit
fi
# system binary 디렉토리 확인 및 생성
if [ ! -d "$SBIN_DIR" ]; then
  echo "Creating $SBIN_DIR directory..."
  mkdir -p "$SBIN_DIR"
fi

# .config 디렉토리 확인 및 생성
if [ ! -d "$CONFIG_DIR" ]; then
  echo "Creating $CONFIG_DIR directory..."
  mkdir -p "$CONFIG_DIR"
fi

# .config/systemd 디렉토리 확인 및 생성
if [ ! -d "$SYSTEMD_DIR" ]; then
  echo "Creating $SYSTEMD_DIR directory..."
  mkdir -p "$SYSTEMD_DIR"
fi

# .config/systemd/user 디렉토리 확인 및 생성
if [ ! -d "$USER_DIR" ]; then
  echo "Creating $USER_DIR directory..."
  mkdir -p "$USER_DIR"
else
  echo "$USER_DIR already exists. Skipping directory creation."
fi
echo $PWD
# MySQL IMQA 서비스 등록
echo "[IMQA] Registering MySQL service to system daemon as user"
if [ $(confirm "Do you want to register MySQL service as non-root user? ($(whoami))") -eq "1" ]; then
  # mysql 디렉토리 확인 및 생성
  if [ ! -d "$MYSQL_BASE_PATH" ]; then
    echo "Creating $MYSQL_BASE_PATH directory..."
    mkdir -p "$MYSQL_BASE_PATH"
  fi
  # .scripts 디렉토리 확인 및 생성
  if [ ! -d "$MYSQL_PRE_SCRIPT_PATH" ]; then
    echo "Creating $MYSQL_PRE_SCRIPT_PATH directory..."
    mkdir -p "$MYSQL_PRE_SCRIPT_PATH"
  fi
  read -p "Enter the full path of mysql data path (default $HOME/mysql): " MYSQL_DATA
  # if mysql data is null, set default data
  if [ -z "$MYSQL_DATA" ]; then
    export MYSQL_DATA="$HOME/mysql"
  fi
  read -p "Enter the full path of mysql log path (default $HOME/mysql): " MYSQL_LOG
  # if mysql log is null, set default log
  if [ -z "$MYSQL_LOG" ]; then
    export MYSQL_LOG="$HOME/mysql"
  fi
  read -p "Enter the full path of mysql socket path (default $HOME/mysql/mysqld.sock): " MYSQL_SOCKET
  # if mysql socket is null, set default socket
  if [ -z "$MYSQL_SOCKET" ]; then
    export MYSQL_SOCKET="$HOME/mysql/mysqld.sock"
  fi
  read -p "Enter the full path of mysql pid path (default $HOME/mysql/mysqld.pid): " MYSQL_PID
  # if mysql pid is null, set default pid
  if [ -z "$MYSQL_PID" ]; then
    export MYSQL_PID="$HOME/mysql/mysqld.pid"
  fi
  read -p "Enter the port of mysql (default 3306): " MYSQL_PORT
  # if mysql port is null, set default port
  if [ -z "$MYSQL_PORT" ]; then
    export MYSQL_PORT=3306
  fi
  read -p "Enter Initial innodb buffer pool size (default 4G): " INNODB_BUFFER_POOL_SIZE
  # if innodb buffer pool size is null, set default size
  if [ -z "$INNODB_BUFFER_POOL_SIZE" ]; then
    export INNODB_BUFFER_POOL_SIZE="4G"
  fi
  read -p "Enter Max connections (default 500): " MAX_CONNECTIONS
  # if max connections is null, set default connections
  if [ -z "$MAX_CONNECTIONS" ]; then
    export MAX_CONNECTIONS=500
  fi
  echo "Registering MySQL service system daemon of user land"
  if [ -f "$MYSQL_SERVICE_FILE_PATH" ]; then
    echo "Copying $MYSQL_SERVICE_FILE to $USER_DIR..."
    cp "$(which mysqld)" "$SBIN_DIR/"
    echo "Templating $MYSQL_SERVICE_FILE_PATH"
    cat "$MYSQL_SERVICE_FILE_PATH" | envsubst >"$USER_DIR/$MYSQL_SERVICE_FILE"
    echo "Templating $MYSQL_CONFIG_FILE_PATH"
    cat "$MYSQL_CONFIG_FILE_PATH" | envsubst >"$HOME/$MYSQL_CONFIG_FILE"
    echo "[IMQA] Written MySQL config file: $HOME/$MYSQL_CONFIG_FILE"
    echo "[IMQA] Please change MySQL config file name from /etc/my.cnf to /etc/my.cnf.bak as sudo"
    echo "[IMQA] Then restart service: systemctl --user restart mysqld@imqa"
    cp "$MYSQL_SERVICE_ENV_FILE_PATH" "$USER_DIR/"
    cp "$MYSQL_PRE_SCRIPT_FILE_PATH" "$MYSQL_PRE_SCRIPT_PATH/"
    systemctl --user daemon-reload
    systemctl --user enable mysqld@imqa
    systemctl --user restart mysqld@imqa
    sleep 5
    echo "[IMQA] Your mysql temporary password is: $(grep -oP "temporary password is generated for root@localhost: \K.*" $MYSQL_LOG/error.log)"
    echo "[IMQA] Please change your mysql password"
  else
    echo "Service file $MYSQL_SERVICE_FILE_PATH not found!"
    exit 1
  fi
else
  echo "[IMQA] Registering MySQL server daemon skipped..."
fi
echo "[IMQA] MySQL client usage: $ mysql --socket=$MYSQL_SOCKET"

echo "Script execution completed."
