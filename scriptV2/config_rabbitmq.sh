#!/usr/bin/env bash

DEFAULT_RABBITMQ_BASE_PATH="$HOME/rabbitmq"
RABBITMQ_SERVICE_FILE="rabbitmq-server@imqa.service"
RABBITMQ_SERVICE_FILE_PATH="$PWD/template/rabbitmq/$RABBITMQ_SERVICE_FILE"
RABBITMQ_CONFIG="rabbitmq.conf"
RABBITMQ_CONFIG_PATH="$PWD/template/rabbitmq/$RABBITMQ_CONFIG"
RABBITMQ_CONFIG_DEFINITION_FILE=definition.json
RABBITMQ_CONFIG_DEFINITION_FILE_PATH="$PWD/template/rabbitmq/$RABBITMQ_CONFIG_DEFINITION_FILE"

encode_password() {
  SALT=$(od -A n -t x -N 4 /dev/urandom)
  PASS=$SALT$(echo -n $1 | xxd -ps | tr -d '\n' | tr -d ' ')
  PASS=$(echo -n $PASS | xxd -r -p | sha256sum | head -c 128)
  PASS=$(echo -n $SALT$PASS | xxd -r -p | base64 | tr -d '\n')
  echo $PASS
}

echo "[IMQA] Registering RabbitMQ service to system daemon as non-sudo user"
export RABBITMQ_BASE_PATH=$(read_input "Enter the full path of RabbitMQ base path: " "$DEFAULT_RABBITMQ_BASE_PATH")
export RABBITMQ_CONFIG_FILES=$(read_input "Enter the full path of RabbitMQ config path: " "$RABBITMQ_BASE_PATH/conf.d")
export RABBITMQ_USERNAME=$(read_input "Enter the default username for RabbitMQ (default admin): ", "admin")
export RABBITMQ_PASSWORD=$(read_input "Enter the default password for RabbitMQ (default 1234): ", "1234")
export RABBITMQ_PASSWORD_HASH=$(encode_password $RABBITMQ_PASSWORD)

create_dir "$RABBITMQ_BASE_PATH"
create_dir "$RABBITMQ_CONFIG_FILES"

echo "Registering MySQL service system daemon of non-sudo user"

if [ -f "$RABBITMQ_SERVICE_FILE_PATH" ]; then
  echo "Templating $RABBITMQ_SERVICE_FILE_PATH"
  envsubst <"$RABBITMQ_SERVICE_FILE_PATH" >"$USER_DIR/$RABBITMQ_SERVICE_FILE"
  echo "Templating $RABBITMQ_CONFIG"
  envsubst <"$RABBITMQ_CONFIG_PATH" >"$RABBITMQ_CONFIG_FILES/$RABBITMQ_CONFIG"
  echo "Templating $RABBITMQ_CONFIG_DEFINITION_FILE_PATH"
  envsubst <"$RABBITMQ_CONFIG_DEFINITION_FILE_PATH" >"$RABBITMQ_CONFIG_FILES/$RABBITMQ_CONFIG_DEFINITION_FILE"

  systemctl --user daemon-reload
  systemctl --user enable rabbitmq-server@imqa
  systemctl --user restart rabbitmq-server@imqa
else
  echo "Service file $RABBITMQ_SERVICE_FILE_PATH not found!"
  exit 1
fi

# # if RABBITMQ port is not 6379, update selinux port
# if [ "$RABBITMQ_PORT" != "6379" ]; then
#   semanage port -a -t RABBITMQ_port_t -p tcp $RABBITMQ_PORT
# fi
