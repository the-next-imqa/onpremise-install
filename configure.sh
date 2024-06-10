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

echo "[IMQA] Configuring dependencies"
echo "This script will not work if you don't have the following dependencies installed"

echo "[IMQA] Configuring nginx"
if [ $(confirm "Do you want to configure nginx?") -eq "1" ]; then
  # Check if nginx is installed
  echo "[IMQA] Checking nginx installed"
  if [ $(rpm -qa | grep -c nginx) -eq 0 ]; then
    echo "[IMQA] Nginx is not installed"
    echo "[IMQA] Please install nginx first"
    echo "[IMQA] Aborting nginx configuration"
  else
    echo "[IMQA] Nginx is installed"
    echo "[IMQA] Checking nginx status"
    # Check if nginx is running
    if [ $(systemctl is-active nginx) == "active" ]; then
      echo "[IMQA] Nginx is running"
      echo "[IMQA] Stopping nginx"
      systemctl stop nginx
    else
      echo "[IMQA] Nginx is not running"
    fi
    sh script/config_nginx.sh
    echo "[IMQA] Enabling and starting nginx"
    systemctl enable nginx
    systemctl restart nginx
  fi
else
  echo "[IMQA] Skipping nginx configuration"
fi

echo "[IMQA] Configuring Redis"
if [ $(confirm "Do you want to configure Redis?") -eq "1" ]; then
  echo "[IMQA] Checking Redis installed"
  # Check if redis is installed
  if [ $(rpm -qa | grep -c redis) -eq 0 ]; then
    echo "[IMQA] Redis is not installed"
    echo "[IMQA] Please install Redis first"
    echo "[IMQA] Aborting Redis configuration"
  else
    echo "[IMQA] Redis is installed"
    echo "[IMQA] Checking Redis status"
    # Check if redis is running
    if [ $(systemctl is-active redis) == "active" ]; then
      echo "[IMQA] Redis is running"
      echo "[IMQA] Stopping Redis"
      systemctl stop redis
    else
      echo "[IMQA] Redis is not running"
    fi
    sh script/config_redis.sh
    echo "[IMQA] Enabling and starting Redis"
    systemctl enable redis
    systemctl restart redis
  fi
else
  echo "[IMQA] Skipping Redis configuration"
fi

echo "[IMQA] Configuring HAProxy"
if [ $(confirm "Do you want to configure HAProxy?") -eq "1" ]; then
  echo "[IMQA] Checking HAProxy installed"
  # Check if haproxy is installed
  if [ $(rpm -qa | grep -c haproxy) -eq 0 ]; then
    echo "[IMQA] HAProxy is not installed"
    echo "[IMQA] Please install HAProxy first"
    echo "[IMQA] Aborting HAProxy configuration"
  else
    echo "[IMQA] HAProxy is installed"
    echo "[IMQA] Checking HAProxy status"
    # Check if haproxy is running
    if [ $(systemctl is-active haproxy) == "active" ]; then
      echo "[IMQA] HAProxy is running"
      echo "[IMQA] Stopping HAProxy"
      systemctl stop haproxy
    else
      echo "[IMQA] HAProxy is not running"
    fi
    sh script/config_haproxy.sh
    systemctl enable haproxy
    systemctl restart haproxy
  fi
else
  echo "[IMQA] Skipping HAProxy configuration"
fi

echo "[IMQA] Configuring RabbitMQ"
if [ $(confirm "Do you want to configure RabbitMQ?") -eq "1" ]; then
  echo "[IMQA] Checking RabbitMQ installed"
  # Check if rabbitmq is installed
  if [ $(rpm -qa | grep -c rabbitmq) -eq 0 ]; then
    echo "[IMQA] RabbitMQ is not installed"
    echo "[IMQA] Please install RabbitMQ first"
    echo "[IMQA] Aborting RabbitMQ configuration"
  else
    echo "[IMQA] RabbitMQ is installed"
    echo "[IMQA] Checking RabbitMQ status"
    # Check if rabbitmq is running
    if [ $(systemctl is-active rabbitmq-server) == "active" ]; then
      echo "[IMQA] RabbitMQ is running"
      sh script/config_rabbitmq.sh
      echo "[IMQA] Enabling and starting RabbitMQ"
      systemctl enable rabbitmq-server
      systemctl restart rabbitmq-server
    else
      echo "[IMQA] RabbitMQ is not running"
    fi
  fi
else
  echo "[IMQA] Skipping RabbitMQ configuration"
fi

echo "[IMQA] Configuring MySQL"
if [ $(confirm "Do you want to configure MySQL?") -eq "1" ]; then
  echo "[IMQA] Checking MySQL installed"
  # Check if mysql is installed
  if [ $(rpm -qa | grep -c mysql) -eq 0 ]; then
    echo "[IMQA] MySQL is not installed"
    echo "[IMQA] Please install MySQL first"
    echo "[IMQA] Aborting MySQL configuration"
  else
    echo "[IMQA] MySQL is installed"
    echo "[IMQA] Checking MySQL status"
    # Check if mysql is running
    if [ $(systemctl is-active mysql) == "active" ]; then
      echo "[IMQA] MySQL is running"
      echo "[IMQA] Stopping MySQL"
      systemctl stop mysqld
    else
      echo "[IMQA] MySQL is not running"
    fi
    sh script/config_mysql.sh
    echo "[IMQA] Enabling and starting MySQL"
    systemctl enable mysqld
    systemctl restart mysqld
  fi
else
  echo "[IMQA] Skipping MySQL configuration"
fi

if [ $(confirm "[IMQA] Do you want to generate IMQA configuration file?") -eq "1" ]; then
  echo "[IMQA] Generating IMQA configuration file"
  sh script/config_configserver.sh
else
  echo "[IMQA] Skipping IMQA configuration file generation"
fi

echo "[IMQA] Configuring IMQA"
echo "[IMQA] Done"