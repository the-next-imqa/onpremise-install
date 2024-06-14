#!/usr/bin/env bash

# using env from upstream
# NGINX_BASE_PATH # nginx base path
# NGINX_CONF_D_PATH # target
NGINX_CONF_FILE_PATH="$PWD/template/nginx/confs"

function generate_conf {
  local template_file=$1
  local output_file=$2
  local origin_port=$3
  local target_port=$4
  local server_domain=$5
  local ssl_cert=$6
  local ssl_key=$7
  local ssl_config=""

  if [ -n "$ssl_cert" ] && [ -n "$ssl_key" ]; then
    ssl_config=$(cat << EOF
    ssl on;
    ssl_certificate $ssl_cert;
    ssl_certificate_key $ssl_key;
    ssl_session_timeout 5m;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_prefer_server_ciphers on;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    if (\$scheme = "https") {
        set \$ssl_header SSL;
    }
    server_name $server_domain;
EOF
)
  fi
  sed -e "s|\${NGINX_BASE_PATH}|$NGINX_BASE_PATH|g" \
      -e "s/\${ORIGIN_PORT}/$origin_port/g" \
      -e "s/\${TARGET_PORT}/$target_port/g" \
      -e "/\${SSL_CONFIG}/{
      r /dev/stdin
      d
      }" $template_file <<< "$ssl_config" > $output_file
}

# Function to handle the configuration for a given service
handle_service() {
  local service_id=$1
  local service_name=$2
  local default_origin_port=$3
  local default_target_port=$4
  local default_cert=$5
  local default_key=$6
  local default_domain=$7

  if confirm "Do you want to add upstream and server block for $service_name?"; then
    local origin_port=$(read_input "Enter the origin port for $service_name: " "$default_origin_port")
    local target_port=$(read_input "Enter the target port for $service_name: " "$default_target_port")
    local ssl_cert=""
    local ssl_key=""
    local server_domain=""

    if confirm "Do you want to add SSL configuration for $service_name?"; then
      ssl_cert=$(read_input "Enter the SSL certificate path: " "$default_cert")
      ssl_key=$(read_input "Enter the SSL certificate key path: " "$default_key")
      server_domain=$(read_input "Enter the server domain for $service_name: " "$default_domain")
    fi

    generate_conf "$NGINX_CONF_FILE_PATH/${service_id}.conf" "$NGINX_CONF_D_PATH/${service_id}.conf" $origin_port $target_port $server_domain $ssl_cert $ssl_key
  fi
}

# WebAPI
handle_service "webapi" "WebAPI" "3580" "80" "$NGINX_BASE_PATH/web_api.crt" "$NGINX_BASE_PATH/web_api.key" "api.imqa.io"

# MPM
handle_service "mpm" "MPM" "3180" "3081" "$NGINX_BASE_PATH/mpm.crt" "$NGINX_BASE_PATH/mpm.key" "mpm.imqa.io"

# Crash
handle_service "crash" "Crash" "3280" "3082" "$NGINX_BASE_PATH/crash.crt" "$NGINX_BASE_PATH/crash.key" "crash.imqa.io"

# WPM
handle_service "wpm" "WPM" "3380" "3084" "$NGINX_BASE_PATH/wpm.crt" "$NGINX_BASE_PATH/wpm.key" "wpm.imqa.io"

# WCrash
handle_service "wcrash" "WCrash" "3480" "3085" "$NGINX_BASE_PATH/wcrash.crt" "$NGINX_BASE_PATH/wcrash.key" "wcrash.imqa.io"

# Account
handle_service "account" "Account" "3080" "3083" "$NGINX_BASE_PATH/account.crt" "$NGINX_BASE_PATH/account.key" "account.imqa.io"