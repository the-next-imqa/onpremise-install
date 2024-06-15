#!/usr/bin/env bash

HAPROXY_CONFIG_FILE="haproxy.cfg"
HAPROXY_CONFIG_FILE_PATH="$PWD/template/haproxy/$HAPROXY_CONFIG_FILE"
HAPROXY_SERVICE_FILE="haproxy@imqa.service"
HAPROXY_SERVICE_FILE_PATH="$PWD/template/haproxy/$HAPROXY_SERVICE_FILE"
HAPROXY_SERVICE_ENV_FILE="haproxy@imqa"
HAPROXY_SERVICe_ENV_FILE_PATH="$PWD/template/haproxy/$HAPROXY_SERVICE_ENV_FILE"

echo "[IMQA] Registering HAProxy service to system daemon as non-sudo user"
export HAPROXY_BASE_PATH=$(read_input "Enter the full path of HAProxy base path" "$HOME/haproxy")
export HAPROXY_CONFIG=$(read_input "Enter the full path of HAProxy config path: " "$HAPROXY_BASE_PATH/$HAPROXY_CONFIG_FILE")
BACKEND_COUNT=$(read_input "How many backend server do you want to configure? " 2)
HAPROXY_SSL_PATH=$(read_input "Enthe the path of HAProxy SSL certs path" "$HAPROXY_BASE_PATH/certs")
HAPROXY_SSL_PEM_FILE=$(read_input "Enter HAProxy SSL pem file: " "ssl.pem")

export HAPROXY_SSL_PEM="$HAPROXY_SSL_PATH/$HAPROXY_SSL_PEM_FILE"

export COLLECTOR_DOMAIN=$(read_input "Enter the collector domain" "collector.imqa.io")
export HAPROXY_PORT=$(read_input "Enter the open port for HAProxy" "443")

export HAPROXY_CHROOT_PATH="$HAPROXY_BASE_PATH/haproxy"
export HAPROXY_STATS_SOCKET_PATH="$HAPROXY_BASE_PATH/admin.sock"
export HAPROXY_DH_PARAM_FILE="$HAPROXY_BASE_PATH/dhparams.pem"
export HAPROXY_ERROR_FILE_PATH="$HAPROXY_BASE_PATH/error"

export HAPROXY_CONFIG="$HAPROXY_BASE_PATH/$HAPROXY_CONFIG_FILE"
export HAPROXY_PIDFILE="$HAPROXY_BASE_PATH/haproxy.pid"
export HAPROXY_CFGDIR="$HAPROXY_BASE_PATH/conf.d"
export HAPROXY_ENV_FILE="$USER_DIR/$HAPROXY_SERVICE_ENV_FILE"

create_dir "$HAPROXY_BASE_PATH"
create_dir "$HAPROXY_CFGDIR"
create_dir "$HAPROXY_CHROOT_PATH"
create_dir "$HAPROXY_ERROR_FILE_PATH"
create_dir "$HAPROXY_SSL_PATH"

BACKENDS=""
for i in $(seq 1 $BACKEND_COUNT); do
    BACKEND_SERVER_IP=$(read_input "Enter the backend server $i IP" "localhost")
    BACKEND_SERVER_PORT=$(read_input "Enter the backend server $i port" $((1000 * $i + 2000))
    BACKENDS+="    server MPMCollectorApi0$i $BACKEND_SERVER_IP:$BACKEND_SERVER_PORT cookie s1 check ssl verify none inter 5000 fastinter 1000 rise 1 fall 1 weight 1\n"
done
export BACKENDS

echo "Registering MySQL service system daemon of non-sudo user"

if [ -f "$HAPROXY_SERVICE_FILE_PATH" ]; then
  echo "Copying executable binary to $SBIN_DIR..."
  # 설치된 상황에 따라 실행 바이너리 위치 확인 필요
  cp "$(which haproxy)" "$SBIN_DIR/"

  echo "Templating $HAPROXY_SERVICE_FILE_PATH"
  envsubst <"$HAPROXY_SERVICE_FILE_PATH"  | sed -e 's/$!/$/g' >"$USER_DIR/$HAPROXY_SERVICE_FILE"
  echo "Copy service env"
  cp $HAPROXY_SERVICe_ENV_FILE_PATH "$USER_DIR/$HAPROXY_SERVICE_ENV_FILE"

  echo "Templating $HAPROXY_CONFIG_FILE_PATH"
  envsubst <"$HAPROXY_CONFIG_FILE_PATH" >"$HAPROXY_BASE_PATH/$HAPROXY_CONFIG_FILE"
  systemctl --user daemon-reload
  systemctl --user enable haproxy@imqa
  systemctl --user restart haproxy@imqa
else
  echo "Service file $HAPROXY_SERVICE_FILE_PATH not found!"
  exit 1
fi
