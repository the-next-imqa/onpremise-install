#!/usr/bin/env bash

export REDIS_PORT=6379
export REDIS_PASSWORD=1234
export REDIS_LOG_PATH=/var/log/redis/redis-server.log
export REDIS_CONFIG=/home/test/configs # redis.conf 저장될 위치 /etc/redis 만들어서 추가해도 됨.

cat redis.conf.template | envsubst > redis.conf
cat redis.service.template | envsubst > redis.service

# TODO: Copy redis.service to /usr/lib/systemd/system/redis.service
# systemctl enable redis.service or systemctl reload redis.service

