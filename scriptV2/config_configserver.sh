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

echo "[IMQA] Composing config file"
read -p "Enter the full path of the config file: " CONFIG_FILE
echo "[IMQA] Generating config file to $CONFIG_FILE"
if [ $(confirm "Do you want to continue?") -eq "1" ]; then
  read -p "Enter the path of project folder (default /APP/project): " PROJECT_FOLDER
  # Global SSL Certificate
  read -p "Enter ssl key path (default ./config/keys/imqa_key.pem): " SSL_KEY
  if [ -z "$SSL_KEY" ]; then
    SSL_KEY="./config/keys/imqa_key.pem"
  fi
  read -p "Enter ssl cert path (default ./config/keys/imqa_cert.pem): " SSL_CERT
  if [ -z "$SSL_CERT" ]; then
    SSL_CERT="./config/keys/imqa_cert.pem"
  fi

  # Global Database
  read -p "Enter the database host (default localhost): " DB_HOST
  if [ -z "$DB_HOST" ]; then
    DB_HOST="localhost"
  fi
  read -p "Enter the database port (default 3306): " DB_PORT
  if [ -z "$DB_PORT" ]; then
    DB_PORT=3306
  fi
  read -p "Enter the database user (default root): " DB_USER
  if [ -z "$DB_USER" ]; then
    DB_USER="root"
  fi
  read -p "Enter the database password (default 1234): " DB_PASS
  if [ -z "$DB_PASS" ]; then
    DB_PASS="1234"
  fi

  # Global Domain Setup
  read -p "Enter the cookie domain (default .imqa.io): " COOKIE_DOMAIN
  if [ -z "$COOKIE_DOMAIN" ]; then
    COOKIE_DOMAIN=".imqa.io"
  fi

  # Global Host Setup
  read -p "Enter the account host (default account.imqa.io): " ACCOUNT_HOST
  if [ -z "$ACCOUNT_HOST" ]; then
    ACCOUNT_HOST="account.imqa.io"
  fi
  read -p "Enter the mpm host (default mpm.imqa.io): " MPM_HOST
  if [ -z "$MPM_HOST" ]; then
    MPM_HOST="mpm.imqa.io"
  fi
  read -p "Enter the wpm host (default wpm.imqa.io): " WPM_HOST
  if [ -z "$WPM_HOST" ]; then
    WPM_HOST="wpm.imqa.io"
  fi
  read -p "Enter the crash host (default crash.imqa.io): " CRASH_HOST
  if [ -z "$CRASH_HOST" ]; then
    CRASH_HOST="crash.imqa.io"
  fi
  read -p "Enter the wcrash host (default wcrash.imqa.io): " WCRASH_HOST
  if [ -z "$WCRASH_HOST" ]; then
    WCRASH_HOST="wcrash.imqa.io"
  fi
  read -p "Enter full url of approved host (default http://account.imqa.io): " APPROVE_HOST

  # Global MQ Setup
  read -p "Enter the MQ host (default localhost): " MQ_HOST
  if [ -z "$MQ_HOST" ]; then
    MQ_HOST="localhost"
  fi
  read -p "Enter the MQ port (default 5672): " MQ_PORT
  if [ -z "$MQ_PORT" ]; then
    MQ_PORT=5672
  fi
  read -p "Enter the MQ user (default admin): " MQ_USER
  if [ -z "$MQ_USER" ]; then
    MQ_USER="admin"
  fi
  read -p "Enter the MQ password (default 1234): " MQ_PASS
  if [ -z "$MQ_PASS" ]; then
    MQ_PASS="1234"
  fi

  # Global Redis Setup
  read -p "Enter the Redis host (default localhost): " REDIS_HOST
  if [ -z "$REDIS_HOST" ]; then
    REDIS_HOST="localhost"
  fi
  read -p "Enter the Redis port (default 6379): " REDIS_PORT
  if [ -z "$REDIS_PORT" ]; then
    REDIS_PORT=6379
  fi
  read -p "Enter the Redis password (default 1234): " REDIS_PASS
  if [ -z "$REDIS_PASS" ]; then
    REDIS_PASS="1234"
  fi

  # Stack Service Setup
  read -p "Enter the stack service host (default localhost): " STACK_SERVICE_HOST
  if [ -z "$STACK_SERVICE_HOST" ]; then
    STACK_SERVICE_HOST="localhost"
  fi
  read -p "Enter the stack service port (default 10893): " STACK_SERVICE_PORT
  if [ -z "$STACK_SERVICE_PORT" ]; then
    STACK_SERVICE_PORT=10893
  fi
  read -p "Enter the stack decoder host (default localhost): " STACK_DECODER_HOST
  if [ -z "$STACK_DECODER_HOST" ]; then
    STACK_DECODER_HOST="localhost"
  fi
  read -p "Enter the stack decoder port (default 10990): " STACK_DECODER_PORT
  if [ -z "$STACK_DECODER_PORT" ]; then
    STACK_DECODER_PORT=10990
  fi

  # Global Alert Server
  read -p "Enter the alert server host (default localhost): " ALERT_SERVER
  if [ -z "$ALERT_SERVER" ]; then
    ALERT_SERVER="localhost"
  fi
  read -p "Enter the alert server port (default 5005): " ALERT_SERVER_PORT
  if [ -z "$ALERT_SERVER_PORT" ]; then
    ALERT_SERVER_PORT=5005
  fi

  # Global Configuration
  read -p "Enter how many days to keep callstack (default 15): " CALLSTACK_RANGE
  if [ -z "$CALLSTACK_RANGE" ]; then
    CALLSTACK_RANGE=15
  fi
  read -p "Enter how many days to keep summary (default 1440): " SUMMARY_RANGE
  if [ -z "$SUMMARY_RANGE" ]; then
    SUMMARY_RANGE=1440
  fi
  read -p "Enter how many days to keep data (default 15): " RANGE
  if [ -z "$RANGE" ]; then
    RANGE=15
  fi
  read -p "Enter how many rows to delete (default 3000): " DELETE_ROW_COUNT
  if [ -z "$DELETE_ROW_COUNT" ]; then
    DELETE_ROW_COUNT=3000
  fi
  read -p "Enter how many days to keep deleted project (default 30): " PROJECT_RANGE
  if [ -z "$PROJECT_RANGE" ]; then
    PROJECT_RANGE=30
  fi

  export SSL_KEY SSL_CERT DB_HOST DB_PORT DB_USER DB_PASS COOKIE_DOMAIN ACCOUNT_HOST MPM_HOST WPM_HOST CRASH_HOST WCRASH_HOST MQ_HOST MQ_PORT MQ_USER MQ_PASS REDIS_HOST REDIS_PORT REDIS_PASS STACK_SERVICE_HOST STACK_SERVICE_PORT STACK_DECODER_HOST STACK_DECODER_PORT ALERT_SERVER ALERT_SERVER_PORT CALLSTACK_RANGE SUMMARY_RANGE RANGE DELETE_ROW_COUNT PROJECT_RANGE

  cat template/credentials.json.template | envsubst > $CONFIG_FILE

else
  echo "[IMQA] Aborting config file generation"
fi