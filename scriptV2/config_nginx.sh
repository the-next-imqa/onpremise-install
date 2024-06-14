#!/usr/bin/env bash

NGINX_SERVICE_FILE="nginx@imqa.service"
NGINX_SERVICE_FILE_PATH="$PWD/template/nginx/$NGINX_SERVICE_FILE"
NGINX_CONFIG_FILE="nginx.conf"
NGINX_CONFIG_FILE_PATH="$PWD/template/nginx/$NGINX_CONFIG_FILE"
NGINX_CONFD_SCRIPT="$PWD/template/nginx/confs/configure.sh"

if [ "$EUID" == 0 ]; then
  echo "Do not run as sudoer"
  exit
fi

echo "[IMQA] Registering NGINX service to system daemon as non-sudo user"

export NGINX_BASE_PATH=$(read_input "Enter the full path of Nginx base path" "$HOME/nginx")
export NGINX_CONF_D_PATH=$(read_input "Enter the full path of Nginx conf.d path. Should end with trailing /" "$NGINX_BASE_PATH/conf.d/")

export NGINX_ERROR_LOG_PATH="$NGINX_BASE_PATH/error.log"
export NGINX_PID_PATH="$NGINX_BASE_PATH/nginx.pid"
export NGINX_DYNAMIC_MODULES_PATH="$NGINX_BASE_PATH/modules/*.conf"
export NGINX_CONFIG="$NGINX_BASE_PATH/nginx.conf"

create_dir "$NGINX_BASE_PATH"
create_dir "$NGINX_CONF_D_PATH"

echo "Registering NGINX service system daemon of non-sudo user"
if [ -f "$NGINX_SERVICE_FILE_PATH" ]; then
  echo "Copying $NGINX_SERVICE_FILE to $USER_DIR..."
  cp "$(which nginx)" "$SBIN_DIR/"
  echo "Templating $NGINX_SERVICE_FILE_PATH"
  envsubst <"$NGINX_SERVICE_FILE_PATH" >"$USER_DIR/$NGINX_SERVICE_FILE"
  echo "Templating $NGINX_CONFIG_FILE_PATH"
  envsubst <"$NGINX_CONFIG_FILE_PATH" | sed -e 's/$!/$/g' >"$NGINX_CONFIG"

  if confirm "Do you want to generate IMQA nginx conf files?"; then
    sh $NGINX_CONFD_SCRIPT
  fi

  systemctl --user daemon-reload
  systemctl --user enable nginx@imqa
  systemctl --user restart nginx@imqa
else
  echo "Service file $NGINX_SERVICE_FILE_PATH not found!"
  exit 1
fi
