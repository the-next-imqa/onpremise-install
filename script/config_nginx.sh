#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

function ssl_check {
  # Setup ssl
  if [ $(confirm "Do you want to add SSL configuration?") -eq "1" ]; then
    read -p "Enter the SSL certificate path: " SSL_CERT
    read -p "Enter the SSL certificate key path: " SSL_KEY
    echo "    ssl on;
    ssl_certificate $SSL_CERT;
    ssl_certificate_key $SSL_KEY;
    ssl_session_timeout 5m;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_prefer_server_ciphers  on;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    if (\$scheme = "https") {
        set \$ssl_header SSL;
    }
" >> $1
    read -p "Enter the server domain: " SERVER_DOMAIN
    echo "server_name $SERVER_DOMAIN;" >> $1
  fi
}

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

echo "[IMQA] Creating Nginx Config"
read -p "Enter the full path of the nginx config folder: " NGINX_CONF
# if null then default /etc/nginx/conf.d
NGINX_CONF=${NGINX_CONF:-/etc/nginx/conf.d}

# Step 0. Add upstream and server block for WebAPI
if [ $(confirm "Do you want to add upstream and server block for WebAPI?") -eq "1" ]; then
  read -p "Enter the origin port for WebAPI (default 3580): " WEBAPI_PORT
  # if null then default 3580
  WEBAPI_PORT=${WEBAPI_PORT:-3580}
  rm -rf $NGINX_CONF/webapi.conf
  echo "upstream webapi {
    server localhost:$WEBAPI_PORT;
}" >> $NGINX_CONF/webapi.conf
fi

# Step 1. Add upstream and server block for MPM
if [ $(confirm "Do you want to add upstream and server block for MPM?") -eq "1" ]; then
  read -p "Enter the origin port for MPM (default 3180): " MPM_PORT
  # if null then default 3180
  MPM_PORT=${MPM_PORT:-3180}
  read -p "Enter the target port for MPM (default 3081): " MPM_TARGET_PORT
  # if null then default 3081
  MPM_TARGET_PORT=${MPM_TARGET_PORT:-3081}
  rm -rf $NGINX_CONF/mpm.conf
  echo "upstream mpm {
    server localhost:$MPM_PORT;
}" >> $NGINX_CONF/mpm.conf
  echo "server {
    listen $MPM_TARGET_PORT;" >> $NGINX_CONF/mpm.conf
  $(ssl_check $NGINX_CONF/mpm.conf)
  echo "
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location /api/project {
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /api/user/ {
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /api {
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location / {
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_set_header Connection keep-alive;
        proxy_pass \$scheme://mpm;
        proxy_http_version 1.1;
        proxy_buffering off;
  }

    location /ws {
        proxy_pass \$scheme://mpm;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}" >> $NGINX_CONF/mpm.conf
fi

# Step 2. Add upstream and server block for Crash
if [ $(confirm "Do you want to add upstream and server block for Crash?") -eq "1" ]; then
  read -p "Enter the origin port for Crash (default 3280): " CRASH_PORT
  # if null then default 3280
  CRASH_PORT=${CRASH_PORT:-3280}
  read -p "Enter the target port for Crash (default 3082): " CRASH_TARGET_PORT
  # if null then default 3082
  CRASH_TARGET_PORT=${CRASH_TARGET_PORT:-3082}
  rm -rf $NGINX_CONF/crash.conf
  echo "upstream crash {
    server localhost:$CRASH_PORT;
}" >> $NGINX_CONF/crash.conf
  echo "server {
    listen $CRASH_TARGET_PORT;" >> $NGINX_CONF/crash.conf
  $(ssl_check $NGINX_CONF/crash.conf)
  echo "
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location /api {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /static/webview {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location / {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://crash;
        proxy_http_version 1.1;
    }
}" >> $NGINX_CONF/crash.conf
fi

# Step 3. Add upstream and server block for WPM
if [ $(confirm "Do you want to add upstream and server block for WPM?") -eq "1" ]; then
  read -p "Enter the origin port for WPM (default 3380): " WPM_PORT
  # if null then default 3380
  WPM_PORT=${WPM_PORT:-3380}
  read -p "Enter the target port for WPM (default 3084): " WPM_TARGET_PORT
  # if null then default 3084
  WPM_TARGET_PORT=${WPM_TARGET_PORT:-3084}
  rm -rf $NGINX_CONF/wpm.conf
  echo "upstream wpm {
    server localhost:$WPM_PORT;
}" >> $NGINX_CONF/wpm.conf
  echo "server {
    listen $WPM_TARGET_PORT;" >> $NGINX_CONF/wpm.conf
  $(ssl_check $NGINX_CONF/wpm.conf)
  echo "
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location /api {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /api/project {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /api/user/ {
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /static/webview {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location / {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://wpm;
        proxy_http_version 1.1;
    }
    location /ws {
        proxy_set_header Host \$http_host;
        proxy_set_header X-Scheme \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://wpm;
        proxy_http_version 1.1;
  }
}" >> $NGINX_CONF/wpm.conf
fi

# Step 4. Add upstream and server block for WCrash
if [ $(confirm "Do you want to add upstream and server block for WCrash?") -eq "1" ]; then
  read -p "Enter the origin port for WCrash (default 3480): " WCRASH_PORT
  # if null then default 3480
  WCRASH_PORT=${WCRASH_PORT:-3480}
  read -p "Enter the target port for WCrash (default 3085): " WCRASH_TARGET_PORT
  # if null then default 3085
  WCRASH_TARGET_PORT=${WCRASH_TARGET_PORT:-3085}
  rm -rf $NGINX_CONF/wcrash.conf
  echo "upstream wcrash {
    server localhost:$WCRASH_PORT;
}" >> $NGINX_CONF/wcrash.conf
  echo "server {
    listen $WCRASH_TARGET_PORT;" >> $NGINX_CONF/wcrash.conf
  $(ssl_check $NGINX_CONF/wcrash.conf)
  echo "
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location /api {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /api/project {
        proxy_pass_header Server;
            proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /api/user/ {
        proxy_pass_header Server;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /static/webview {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location / {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://wcrash;
        proxy_http_version 1.1;
    }
}" >> $NGINX_CONF/wcrash.conf
fi

# Step 5. Add upstream and server block for Account
if [ $(confirm "Do you want to add upstream and server block for Account?") -eq "1" ]; then
  read -p "Enter the origin port for Account (default 3080): " ACCOUNT_PORT
  # if null then default 3080
  ACCOUNT_PORT=${ACCOUNT_PORT:-3080}
  read -p "Enter the target port for Account (default 3083): " ACCOUNT_TARGET_PORT
  # if null then default 3083
  ACCOUNT_TARGET_PORT=${ACCOUNT_TARGET_PORT:-3083}
  rm -rf $NGINX_CONF/account.conf
  echo "upstream account {
    server localhost:$ACCOUNT_PORT;
}" >> $NGINX_CONF/account.conf
  echo "server {
    listen $ACCOUNT_TARGET_PORT;" >> $NGINX_CONF/account.conf
  $(ssl_check $NGINX_CONF/account.conf)
  echo "
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location /api {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location /static/webview {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://webapi;
        proxy_http_version 1.1;
    }

    location / {
        proxy_pass_header Server;
        proxy_set_header X-Proto \$ssl_header;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Scheme \$scheme;
        proxy_pass \$scheme://account;
        proxy_http_version 1.1;
    }
}" >> $NGINX_CONF/account.conf
fi

echo "[IMQA] Nginx Config is created"
echo "Please check the config files in $NGINX_CONF"
echo "You can check the nginx config by running 'nginx -t'"
echo "[IMQA] Nginx configuration is done"
echo "[IMQA] Ngnix restart"
systemctl enable nginx
systemctl restart nginx