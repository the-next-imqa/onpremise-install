#!/usr/bin/env bash

REDIS_BASE_PATH="$HOME/redis"
REDIS_CONFIG_FILE="redis.conf"
REDIS_CONFIG_FILE_PATH="$PWD/template/redis/$REDIS_CONFIG_FILE"
REDIS_SERVICE_FILE="redis@imqa.service"
REDIS_SERVICE_FILE_PATH="$PWD/template/redis/$REDIS_SERVICE_FILE"

create_dir "$REDIS_BASE_PATH"

echo "[IMQA] Registering Redis service to system daemon as non-sudo user"
export REDIS_CONFIG=$(read_input "Enter the full path of redis config path: " "$HOME/redis")
export REDIS_PORT=$(read_input "Enter Redis port" "6379")
export REDIS_PASSWORD=$(read_input "Enter Redis password", "1234")
export REDIS_LOG_PATH=$(read_input "Enter Redis log path", "$REDIS_BASE_PATH/redis-server.log")
export REDIS_PID_PATH=$(read_input "Enter Redis pid path", "$REDIS_BASE_PATH/redis-server.pid")

echo "Registering MySQL service system daemon of non-sudo user"

if [ -f "$REDIS_SERVICE_FILE_PATH" ]; then
  echo "Copying executable binary to $SBIN_DIR..."
  cp "/usr/bin/redis-server" "$SBIN_DIR/"
  cp "/usr/libexec/redis-shutdown" "$SBIN_DIR/"
  echo "Templating $REDIS_SERVICE_FILE_PATH"
  envsubst <"$REDIS_SERVICE_FILE_PATH" >"$USER_DIR/$REDIS_SERVICE_FILE"
  echo "Templating $REDIS_CONFIG_FILE_PATH"
  envsubst <"$REDIS_CONFIG_FILE_PATH" >"$REDIS_BASE_PATH/$REDIS_CONFIG_FILE"
  systemctl --user daemon-reload
  systemctl --user enable redis@imqa
  systemctl --user restart redis@imqa
else
  echo "Service file $REDIS_SERVICE_FILE_PATH not found!"
  exit 1
fi

# # if redis port is not 6379, update selinux port
# if [ "$REDIS_PORT" != "6379" ]; then
#   semanage port -a -t redis_port_t -p tcp $REDIS_PORT
# fi
