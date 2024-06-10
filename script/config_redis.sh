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
  echo "bind 0.0.0.0
protected-mode yes
port $REDIS_PORT
tcp-backlog 511
timeout 100
tcp-keepalive 300
daemonize yes
supervised no
pidfile \"/var/run/redis/redis-server.pid\"
loglevel notice
logfile \"$REDIS_LOG_PATH\"
databases 16
stop-writes-on-bgsave-error no
rdbcompression yes
rdbchecksum yes
dbfilename \"dump.rdb\"
dir \"/var/lib/redis\"
masterauth \"$REDIS_PASSWORD\"
slave-serve-stale-data yes
slave-read-only no
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-ping-slave-period 10
repl-timeout 15
repl-disable-tcp-nodelay no
slave-priority 100
requirepass \"$REDIS_PASSWORD\"
maxclients 10000
lazyfree-lazy-eviction yes
lazyfree-lazy-expire yes
lazyfree-lazy-server-del yes
slave-lazy-flush yes
appendonly no
appendfilename \"appendonly.aof\"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events \"\"
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes" > $REDIS_CONFIG/redis.conf

# if redis port is not 6379, update selinux port
if [ "$REDIS_PORT" != "6379" ]; then
  semanage port -a -t redis_port_t -p tcp $REDIS_PORT
fi

echo "[IMQA] Redis configuration is done"