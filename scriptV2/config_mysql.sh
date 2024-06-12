#!/usr/bin/env bash

MYSQL_BASE_PATH="$HOME/mysql"
MYSQL_CONFIG_FILE="my.cnf"
MYSQL_CONFIG_FILE_PATH="$PWD/template/mysql/$MYSQL_CONFIG_FILE"
MYSQL_PRE_SCRIPT_FILE="mysqld_pre_systemd"
MYSQL_PRE_SCRIPT_FILE_PATH="$PWD/template/mysql/$MYSQL_PRE_SCRIPT_FILE"
MYSQL_SERVICE_FILE="mysqld@imqa.service"
MYSQL_SERVICE_FILE_PATH="$PWD/template/mysql/$MYSQL_SERVICE_FILE"
MYSQL_SERVICE_ENV_FILE="mysqld@imqa"
MYSQL_SERVICE_ENV_FILE_PATH="$PWD/template/mysql/$MYSQL_SERVICE_ENV_FILE"

if [ "$EUID" == 0 ]; then
  echo "Do not run as sudoer"
  exit
fi

echo "[IMQA] Registering MySQL service to system daemon as non-sudo user"

create_dir "$MYSQL_BASE_PATH"

export MYSQL_DATA=$(read_input "Enter the full path of mysql data path" "$HOME/mysql")
export MYSQL_LOG=$(read_input "Enter the full path of mysql log path" "$HOME/mysql")
export MYSQL_SOCKET=$(read_input "Enter the full path of mysql socket path" "$HOME/mysql/mysqld.sock")
export MYSQL_PID=$(read_input "Enter the full path of mysql pid path" "$HOME/mysql/mysqld.pid")
export MYSQL_PORT=$(read_input "Enter the port of mysql" "3306")
export INNODB_BUFFER_POOL_SIZE=$(read_input "Enter Initial innodb buffer pool size" "4G")
export MAX_CONNECTIONS=$(read_input "Enter Max connections" "500")

echo "Registering MySQL service system daemon of non-sudo user"
if [ -f "$MYSQL_SERVICE_FILE_PATH" ]; then
  echo "Copying $MYSQL_SERVICE_FILE to $USER_DIR..."
  cp "$(which mysqld)" "$SBIN_DIR/"
  echo "Templating $MYSQL_SERVICE_FILE_PATH"
  envsubst <"$MYSQL_SERVICE_FILE_PATH" >"$USER_DIR/$MYSQL_SERVICE_FILE"
  echo "Templating $MYSQL_CONFIG_FILE_PATH"
  envsubst <"$MYSQL_CONFIG_FILE_PATH" >"$HOME/$MYSQL_CONFIG_FILE"
  echo "[IMQA] Written MySQL config file: $HOME/$MYSQL_CONFIG_FILE"
  echo "[IMQA] Please change MySQL config file name from /etc/my.cnf to /etc/my.cnf.bak as sudo"
  echo "[IMQA] Then restart service: $(tput bold)systemctl --user restart mysqld@imqa$(tput sgr0)"
  cp "$MYSQL_SERVICE_ENV_FILE_PATH" "$USER_DIR/"
  cp "$MYSQL_PRE_SCRIPT_FILE_PATH" "$SCRIPT_PATH/"
  systemctl --user daemon-reload
  systemctl --user enable mysqld@imqa
  systemctl --user restart mysqld@imqa
  sleep 5
  echo "[IMQA] Your mysql temporary password is: $(tput bold)$(grep -oP "temporary password is generated for root@localhost: \K.*" $MYSQL_LOG/error.log)$(tput sgr0)"
  echo "[IMQA] Please change your mysql password"
  echo "[IMQA] MySQL client usage: $(tput bold)mysql --socket=$MYSQL_SOCKET$(tput sgr0)"
else
  echo "Service file $MYSQL_SERVICE_FILE_PATH not found!"
  exit 1
fi
