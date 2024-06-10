#!/usr/bin/env bash

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

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "[IMQA] Installing Redis"
read -p "Enter the full path of redis config path: " REDIS_CONFIG
cp $REDIS_CONFIG/redis.conf $REDIS_CONFIG/redis.conf.bak
rm -rf $REDIS_CONFIG/redis.conf
read -p "Enter Redis port (default 6379): " REDIS_PORT
read -p "Enter Redis password (default 1234): " REDIS_PASSWORD
read -p "Enter Redis log path (default /var/log/redis/redis-server.log): " REDIS_LOG_PATH
# if redis log path is null, set default path
if [ -z "$REDIS_LOG_PATH" ]; then
  REDIS_LOG_PATH="/var/log/redis/redis-server.log"
fi
# if redis port is null, set default port
if [ -z "$REDIS_PORT" ]; then
  REDIS_PORT="6379"
fi
# if redis password is null, set default password
if [ -z "$REDIS_PASSWORD" ]; then
  REDIS_PASSWORD="1234"
fi

export REDIS_PORT REDIS_PASSWORD REDIS_LOG_PATH REDIS_CONFIG

cat redis.conf.template | envsubst > $REDIS_CONFIG/redis.conf
cat redis.service.template | envsubst > /usr/lib/systemd/system/redis.service

# if redis port is not 6379, update selinux port
if [ "$REDIS_PORT" != "6379" ]; then
  semanage port -a -t redis_port_t -p tcp $REDIS_PORT
fi

systemctl reload redis.service
systemctl restart redis.service

echo "[IMQA] Redis configuration is done"