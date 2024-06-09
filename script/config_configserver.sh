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


  cat <<EOF | tee $CONFIG_FILE
{
        "file_name": "credentials.json",
        "mode": "live",
        "mpm_version": "3.15.2",
        "log_level": "INFO",
        "https_options": {
                "key": "./config/keys/imqa_key.pem",
                "cert": "./config/keys/imqa_cert.pem"
        },
        "logging": [
                {
                        "level": "verbose",
                        "type": "Console",
                        "colorize": true,
                        "timestamp": true
                },
                {
                        "level": "file",
                        "type": "File",
                        "timestamp": true,
                        "filename": "/dev/null"
                }
        ],
        "database": {
                "type": "mysql",
                "aosShardNodes": { "aosShard00": 1 },
                "iosShardNodes": { "iosShard00": 1 },
                "unityShardNodes": { "unityShard00": 1 },
                "webShardNodes": { "webShard00": 1 },
                "proxySqlNodes": { "proxySql00": 1 },
                "nodes": {
                        "user": {
                                "host": "$DB_HOST",
                                "port": $DB_PORT,
                                "user": "$DB_USER",
                                "password": "$DB_PASS",
                                "database": "imqa_user",
                                "connectionLimit": 10,
                                "waitForConnections": true,
                                "maxIdle": 10
                        },
                        "proxySql00": {
                                "host": "$DB_HOST",
                                "port": $DB_PORT,
                                "user": "$DB_USER",
                                "password": "$DB_PASS",
                                "flags": "-c",
                                "connectionLimit": 20,
                                "waitForConnections": true,
                                "multipleStatements": true,
                                "maxIdle": 20
                        },
                        "backoffice": {
                                "host": "$DB_HOST",
                                "port": $DB_PORT,
                                "user": "$DB_USER",
                                "password": "$DB_PASS",
                                "database": "imqa_backoffice",
                                "connectionLimit": 20,
                                "waitForConnections": true,
                                "maxIdle": 20
                        }
                },
                "crash": {
                        "aos": "imqa",
                        "ios": "imqa_crash_apple",
                        "unity": "imqa_crash_unity"
                },
                "mpm": { "aos": "imqa_mpm_analysis", "ios": "imqa_mpm_apple" }
        },
        "cookie": {
                "session": "IMQA_SESSION",
                "temp_session": [
                        "IMQA_LOCAL_SESSION",
                        "IMQA_OTE_SESSION",
                        "IMQA_DEV_SESSION",
                        "IMQA_SESSION"
                ],
                "domain": "$COOKIE_DOMAIN"
        },
        "host": {
                "account": "$ACCOUNT_HOST",
                "mpm": "$MPM_HOST",
                "wpm": "$WPM_HOST",
                "crash": "$CRASH_HOST",
                "wcrash": "$WCRASH_HOST",
                "protocol": "https",
                "protocolPrivate": "http"
        },
        "analysisFile": { "local": "$PROJECT_FOLDER/uploads", "maxFileSize": 500000000 },
        "file_server": { "host": "127.0.0.1", "port": 3780, "version": "v1" },
        "ftp": {
                "host": "127.0.0.1",
                "user": "onycom",
                "pass": "!@hyperion78*",
                "port": "22",
                "remote": "$PROJECT_FOLDER/ftp_storage"
        },
        "storage": {
                "name": "imqaanalysisfilestorage",
                "key": "mkMu0wZ4J4pkVMgVgWMcw+Se5hyYBn5P9fSIAnf9WCveHtmeFrzRV8zm/FyTS/lrC6lxHFYTSOg7BCWbPLt2Cw=="
        },
        "pack_secret": "mpm project key generater",
        "jwtsecret": "imqa mpm key secret",
        "saltRound": 5,
        "jwt": { "issuer": "$MPM_HOST", "subject": "mpm", "algorithm": "HS256" },
        "mail": {
                "server": "mail.onycom.com",
                "port": 587,
                "id": "youngsoo@onycom.com",
                "pass": "onycom.com!!",
                "name": "ImQA"
        },
        "gmail": {
                "server": "gmail",
                "id": "no-reply@imqa.io",
                "password": "Djslzja0080",
                "client_id": "258651742311-fvni8dp9jh1t5khodk9ihq8sbeabgfm6.apps.googleusercontent.com",
                "client_secret": "",
                "refresh_token": "1//04nuP_QEDxLE9CgYIARAAGAQSNwF-L9IrmSDaPOjqe5f_3AHvz0-eijmVq2Nb2dIIGDXIwAXwqczUQJGVXUqvigT1_s_16ubCrv4",
                "access_token": "ya29.a0AVA9y1u_PGyont4reJYT4y17emGODCLEJQoqm_T8voWqJRTIMrLzr_xWn5QLiKUKc4P93DHBpvwBNj4mh8sL00L1oVOeyTQazG937gElFn3ldIOIKik3ISIeFN6EHQes0VzFda0NHYpt-BEnofcWAIUwCaGjaCgYKATASATASFQE65dr8o4z-Th6LCfOOt-_gcu4PlQ0163",
                "name": "IMQA"
        },
        "approve_host": "$APPROVE_HOST",
        "mq": {
                "host": "amqp://$MQ_USER:$MQ_PASS@$MQ_HOST:$MQ_PORT/?heartbeat=10",
                "exchanges": "imqa-topic-exchange",
                "AOSCrashQueue": "CrashAosQueue",
                "IOSCrashQueue": "CrashIosQueue",
                "MPMAOSQueue": "MpmAosQueue",
                "MPMIOSQueue": "MpmIosQueue",
                "AosCrashKey": ["crash_aos"],
                "IosCrashKey": ["crash_ios"],
                "MpmAosKey": ["mpm_aos"],
                "MpmIosKey": ["mpm_ios"],
                "WpmKey": ["wpm"],
                "WebCrashKey": ["crash_web"],
                "exchange": "imqa-topic-exchange",
                "CrashAosQueue": "CrashAosQueue",
                "CrashIosQueue": "CrashIosQueue",
                "CrashWebQueue": "CrashWebQueue",
                "MpmAosQueue": "MpmAosQueue",
                "MpmIosQueue": "MpmIosQueue",
                "WpmQueue": "WpmQueue",
                "CrashAosKey": ["crash_aos"],
                "CrashIosKey": ["crash_ios"],
                "CrashWebKey": ["crash_web"],
                "port": $MQ_PORT,
                "login": "$MQ_USER",
                "password": "$MQ_PASS",
                "connectionTimeout": 0,
                "reconnect": true,
                "authMechanism": "AMQPLAIN",
                "vhost": "/"
        },
        "stackMq": {
                "host": "amqp://$MQ_USER:$MQ_PASS@$MQ_HOST:$MQ_PORT/?heartbeat=60",
                "stackExchanges": "imqa-stack-exchange",
                "MpmStackSinkKey": ["mpm"],
                "CrashStackSinkKey": ["crash"],
                "login": "$MQ_USER",
                "password": "$MQ_PASS",
                "vhost": "/"
        },
        "analysisMQ": {
                "host": "amqp://$MQ_USER:$MQ_PASS@$MQ_HOST:$MQ_PORT/?heartbeat=10",
                "port": $MQ_PORT,
                "login": "$MQ_USER",
                "password": "$MQ_PASS",
                "authMechanism": "AMQPLAIN",
                "vhost": "/",
                "qname": "analysis-callstack"
        },
        "errorMQ": {
                "host": "amqp://$MQ_USER:$MQ_PASS@$MQ_HOST:$MQ_PORT/?heartbeat=10",
                "port": $MQ_PORT,
                "login": "$MQ_USER",
                "password": "$MQ_PASS",
                "authMechanism": "AMQPLAIN",
                "vhost": "/",
                "qname": "errorQ"
        },
        "local_redis": [
                {
                        "master": {
                                "host": "$REDIS_HOST",
                                "port": $REDIS_PORT,
                                "pass": "$REDIS_PASS",
                                "retry_unfulfilled_commands": true,
                                "connect_timeout": 10000
                        },
                        "slaves": [{ "host": "$REDIS_HOST", "port": $REDIS_PORT, "pass": "$REDIS_PASS" }]
                }
        ],
        "redis": [
                {
                        "master": {
                                "host": "$REDIS_HOST",
                                "port": $REDIS_PORT,
                                "pass": "$REDIS_PASS",
                                "retry_unfulfilled_commands": true,
                                "connect_timeout": 10
                        },
                        "slaves": [
                                {
                                        "host": "$REDIS_HOST",
                                        "port": $REDIS_PORT,
                                        "pass": "$REDIS_PASS",
                                        "retry_unfulfilled_commands": true,
                                        "connect_timeout": 10
                                }
                        ]
                }
        ],
        "mapping_redis": [
                {
                        "master": {
                                "host": "$REDIS_HOST",
                                "port": $REDIS_PORT,
                                "pass": "$REDIS_PASS",
                                "retry_unfulfilled_commands": true,
                                "connect_timeout": 10
                        }
                }
        ],
        "alert_server": "$ALERT_SERVER:$ALERT_SERVER_PORT",
        "cache_redis": {
                "host": "$REDIS_HOST",
                "port": $REDIS_PORT,
                "db": 3,
                "password": "$REDIS_PASS"
        },
        "cache_config": {
                "useCache": false,
                "criteriaDay": 10,
                "realTimeExpireSecond": 60,
                "currentExprieSecond": 120,
                "todayExpireMinute": 30,
                "aboveCriteriaExpireDay": 3
        },
        "stack_storage": {
                "host": "52.231.193.16",
                "storage_path": "/home/onycom/data",
                "receiver_port": 9000,
                "api_port": 15000
        },
        "stack_api": { "host": "52.231.193.16", "port": 45000, "ssl_port": 46000 },
        "stack_service": { "host": "$STACK_SERVICE_HOST", "port": $STACK_SERVICE_PORT },
        "stack_decoder": { "host": "$STACK_DECODER_HOST", "port": $STACK_DECODER_PORT },
        "worker": {
                "responseTimeCollectionLimitSecond": 1,
                "dataFilter": []
        },
        "collector": {
                "dataFilter": [],
                "wpm": {
                        "useWhiteOrigins": true,
                        "whiteOriginsSource": "cache",
                        "whiteOrigins": {}
                }
        },
        "scheduler": {
                "cleanUp": {
                        "callstack_range": $CALLSTACK_RANGE,
                        "range": $RANGE,
                        "summary_range": $SUMMARY_RANGE,
                        "delete_row_count": $DELETE_ROW_COUNT,
                },
                "projectDelete": { "range": $PROJECT_RANGE }
        },
        "agent_setting": {
                "web_agent": {
                        "url": "https://cdn.imqa.io/agent/web-agent"
                },
                "webview_agent": {
                        "url": "https://cdn.imqa.io/agent/webview-agent"
                }
        },
        "openaiApi": {
                "host": "http://20.249.8.235:8080"
        },
        "password_validation": {
                "easy": ["test", "TEST", "admin", "ADMIN", "imqa", "IMQA"]
        }
}
EOF
else
  echo "[IMQA] Aborting config file generation"
fi