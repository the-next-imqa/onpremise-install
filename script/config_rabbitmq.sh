#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

function confirm {
  while true
  do
    read -p "$1 [y/n] : " yn
    case $yn in
      [Yy] ) echo "1"; break;;
      [Nn] ) echo "0"; break;;
    esac
  done
}

echo "[IMQA] Configuring RabbitMQ"
read -p "Enter the default username for RabbitMQ (default admin): " RABBITMQ_USERNAME
if [ -z "$RABBITMQ_USERNAME" ]; then
  RABBITMQ_USERNAME="admin"
fi
read -p "Enter the default password for RabbitMQ (default 1234): " RABBITMQ_PASSWORD
if [ -z "$RABBITMQ_PASSWORD" ]; then
  RABBITMQ_PASSWORD="1234"
fi
rabbitmqctl add_user $RABBITMQ_USERNAME $RABBITMQ_PASSWORD
rabbitmqctl set_user_tags $RABBITMQ_USERNAME administrator
rabbitmqctl set_permissions -p / $RABBITMQ_USERNAME ".*" ".*" ".*"

if [ $(confirm "Do you want to install RabbitMQ Management Plugin?") -eq "1" ]; then
  rabbitmq-plugins enable rabbitmq_management
fi

echo "[IMQA] RabbitMQ configuration is done"
