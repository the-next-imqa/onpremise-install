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

echo "[IMQA] Configuring HAProxy"
read -p "Enter the full path of haproxy config path: " HAPROXY_CONFIG
# Backup haproxy config if exist
if [ -f "$HAPROXY_CONFIG/haproxy.cfg" ]; then
  cp $HAPROXY_CONFIG/haproxy.cfg $HAPROXY_CONFIG/haproxy.cfg.bak
fi
# Remove haproxy config if exist
rm -rf $HAPROXY_CONFIG/haproxy.cfg

read -p "How many backend server do you want to configure? " BACKEND_SERVER
# if backend server is null, set default server
if [ -z "$BACKEND_SERVER" ]; then
  BACKEND_SERVER=2
fi

echo "global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin
        stats timeout 60s
        user haproxy
        group haproxy
        daemon
        ssl-dh-param-file /etc/haproxy/dhparams.pem
" | tee -a $HAPROXY_CONFIG/haproxy.cfg > /dev/null

echo "defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http
" | tee -a $HAPROXY_CONFIG/haproxy.cfg > /dev/null

read -p "Enter the full path of haproxy ssl pem file (default /etc/haproxy/certs/ssl.pem): " HAPROXY_SSL_PEM
# if haproxy ssl pem file is null, set default pem file
if [ -z "$HAPROXY_SSL_PEM" ]; then
  HAPROXY_SSL_PEM="/etc/haproxy/certs/ssl.pem"
fi
read -p "Enter the collector domain (default collector.imqa.io): " COLLECTOR_DOMAIN
# if collector domain is null, set default domain
if [ -z "$COLLECTOR_DOMAIN" ]; then
  COLLECTOR_DOMAIN="collector.imqa.io"
fi
read -p "Enter the open port for haproxy (default 443): " HAPROXY_PORT
# if haproxy port is null, set default port
if [ -z "$HAPROXY_PORT" ]; then
  HAPROXY_PORT=443
fi

echo "frontend v1_ssl_proxy
        bind *:$HAPROXY_PORT ssl crt $HAPROXY_SSL_PEM
        mode http
        use_backend v1_ssl_server if { ssl_fc_sni $COLLECTOR_DOMAIN }
" | tee -a $HAPROXY_CONFIG/haproxy.cfg > /dev/null

echo "backend v1_ssl_server
        stats enable
        stats uri /admin
        stats hide-version

        option http-server-close
        option forwardfor header X-Real-IP
        balance roundrobin
        cookie SERVERID insert indirect nocache
" | tee -a $HAPROXY_CONFIG/haproxy.cfg > /dev/null

for (( i=1; i<=$BACKEND_SERVER; i++ ))
do
  read -p "Enter the backend server $i ip (default localhost): " BACKEND_SERVER_IP
  # default backend server ip is localhost
  if [ -z "$BACKEND_SERVER_IP" ]; then
    BACKEND_SERVER_IP="localhost"
  fi
  read -p "Enter the backend server $i port (default 1000 * server num + 2000): " BACKEND_SERVER_PORT
  # default backend server port is 1000 * server num
  if [ -z "$BACKEND_SERVER_PORT" ]; then
    BACKEND_SERVER_PORT=$((1000 * $i + 2000))
  fi
  echo "        server MPMCollectorApi0$i $BACKEND_SERVER_IP:$BACKEND_SERVER_PORT cookie s1 check ssl verify none inter 5000 fastinter 1000 rise 1 fall 1 weight 1" | tee -a $HAPROXY_CONFIG/haproxy.cfg > /dev/null
done

echo "[IMQA] HAProxy configuration is done"