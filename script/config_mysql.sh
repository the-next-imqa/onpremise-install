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

echo "[IMQA] Configuring MySQL"
echo "This script will configure MySQL"
echo "Mysql will be reset"
read -p "Enter the full path of mysql config path: " MYSQL_CONFIG
# Backup mysql config if exist
if [ -f "$MYSQL_CONFIG/my.cnf" ]; then
  cp $MYSQL_CONFIG/my.cnf $MYSQL_CONFIG/my.cnf.bak
fi
# Remove mysql config if exist
rm -rf $MYSQL_CONFIG/my.cnf

echo "[IMQA] Configuring MySQL"
# original data path from original config
MYSQL_ORIGINAL_DATA=$(grep -oP "datadir=\K.*" /etc/my.cnf.bak)
if [ -z "$MYSQL_ORIGINAL_DATA" ]; then
  MYSQL_ORIGINAL_DATA="/var/lib/mysql"
fi

read -p "Enter the full path of mysql data path (default /var/lib/mysql): " MYSQL_DATA
# if mysql data is null, set default data
if [ -z "$MYSQL_DATA" ]; then
  MYSQL_DATA="/var/lib/mysql"
fi
read -p "Enter the full path of mysql log path (default /var/log/mysql): " MYSQL_LOG
# if mysql log is null, set default log
if [ -z "$MYSQL_LOG" ]; then
  MYSQL_LOG="/var/log/mysql"
fi
read -p "Enter the full path of mysql socket path (default /var/run/mysqld/mysqld.sock): " MYSQL_SOCKET
# if mysql socket is null, set default socket
if [ -z "$MYSQL_SOCKET" ]; then
  MYSQL_SOCKET="/var/run/mysqld/mysqld.sock"
fi
read -p "Enter the full path of mysql pid path (default /var/run/mysqld/mysqld.pid): " MYSQL_PID
# if mysql pid is null, set default pid
if [ -z "$MYSQL_PID" ]; then
  MYSQL_PID="/var/run/mysqld/mysqld.pid"
fi
read -p "Enter the port of mysql (default 3306): " MYSQL_PORT
# if mysql port is null, set default port
if [ -z "$MYSQL_PORT" ]; then
  MYSQL_PORT=3306
fi
read -p "Enter Initial innodb buffer pool size (default 4G): " INNODB_BUFFER_POOL_SIZE
# if innodb buffer pool size is null, set default size
if [ -z "$INNODB_BUFFER_POOL_SIZE" ]; then
  INNODB_BUFFER_POOL_SIZE="4G"
fi
read -p "Enter Max connections (default 500): " MAX_CONNECTIONS
# if max connections is null, set default connections
if [ -z "$MAX_CONNECTIONS" ]; then
  MAX_CONNECTIONS=500
fi
echo "[mysqld]
datadir=$MYSQL_DATA
socket=$MYSQL_SOCKET
pid-file=$MYSQL_PID
port=$MYSQL_PORT
innodb_buffer_pool_size=$INNODB_BUFFER_POOL_SIZE
max_connections=$MAX_CONNECTIONS
log-error=$MYSQL_LOG/error.log
join_buffer_size = 1G
sort_buffer_size = 32M
read_rnd_buffer_size = 32M
transaction-isolation = READ-COMMITTED
user=mysql
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,REAL_AS_FLOAT,IGNORE_SPACE,ONLY_FULL_GROUP_BY
character-set-client-handshake = FALSE
character-set-server = utf8mb4
init_connect=SET NAMES 'utf8mb4' COLLATE 'utf8mb4_bin'
lower_case_table_names=1
skip-host-cache
skip-name-resolve
max_allowed_packet=1000M
symbolic-links=0

[client]
default-character-set=utf8mb4
" | tee -a $MYSQL_CONFIG/my.cnf > /dev/null

# if mysql port is not 3306, update selinux port
if [ "$MYSQL_PORT" != "3306" ]; then
  semanage port -a -t mysqld_port_t -p tcp $MYSQL_PORT
fi

# Check if mysql log path is exist
if [ ! -d "$MYSQL_LOG" ]; then
  mkdir -p $MYSQL_LOG
  chown -R mysql:mysql $MYSQL_LOG
else
  rm -rf $MYSQL_LOG/*
  mkdir -p $MYSQL_LOG
  chown -R mysql:mysql $MYSQL_LOG
fi

# Check if mysql data path is changed
# mysql version 5.7.x
echo "[IMQA] Re-initializing MySQL"
systemctl stop mysqld
rm -rf $MYSQL_DATA/*
mkdir -p $MYSQL_DATA
systemctl start mysqld
# wait for mysql to start appox 40sec
sleep 40
echo "[IMQA] Your mysql temporary password is: $(grep -oP "temporary password is generated for root@localhost: \K.*" $MYSQL_LOG/error.log)"
echo "[IMQA] Please change your mysql password"
read -p "Do you want to change your mysql password? [y/n] : " CHANGEPASSWORD
if [ "$CHANGEPASSWORD" == "y" ]; then
  read -p "Enter your new mysql password (default 1234): " NEWPASSWORD
  if [ -z "$NEWPASSWORD" ]; then
    NEWPASSWORD="1234"
  fi
  echo "use mysql;
  ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEWPASSWORD';
  FLUSH PRIVILEGES;
  " | mysql --socket=$MYSQL_SOCKET -u root -p$(grep -oP "temporary password is generated for root@localhost: \K.*" $MYSQL_LOG/error.log)
  echo "[IMQA] MySQL password is changed"
  # check if changed password is correct
  mysql --socket=$MYSQL_SOCKET -u root -p$NEWPASSWORD -e "exit"
  if [ $? -eq 0 ]; then
    echo "[IMQA] MySQL password is correct"
    # Create new user for mysql
    read -p "Enter your new mysql username (default imqa): " NEWUSERNAME
    if [ -z "$NEWUSERNAME" ]; then
      NEWUSERNAME="imqa"
    fi
    read -p "Enter your new mysql user password (default 1234): " NEWUSERPASSWORD
    if [ -z "$NEWUSERPASSWORD" ]; then
      NEWUSERPASSWORD="1234"
    fi
    read -p "Enter yout new mysql user host (default %): " NEWUSERHOST
    if [ -z "$NEWUSERHOST" ]; then
      NEWUSERHOST="%"
    fi
    echo "use mysql;
    CREATE USER '$NEWUSERNAME'@'$NEWUSERHOST' IDENTIFIED BY '$NEWUSERPASSWORD';
    GRANT ALL PRIVILEGES ON *.* TO '$NEWUSERNAME'@'$NEWUSERHOST' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    " | mysql --socket=$MYSQL_SOCKET -u root -p$NEWPASSWORD
    # Check if new user is created
    mysql --socket=$MYSQL_SOCKET -u $NEWUSERNAME -p$NEWUSERPASSWORD -e "exit"
    if [ $? -eq 0 ]; then
      echo "[IMQA] MySQL user is created"
    else
      echo "[IMQA] MySQL user is not created"
      echo "try following command to create user"
      echo "CREATE USER '$NEWUSERNAME'@'$NEWUSERHOST' IDENTIFIED BY '$NEWUSERPASSWORD';"
      echo "GRANT ALL PRIVILEGES ON *.* TO '$NEWUSERNAME'@'$NEWUSERHOST' WITH GRANT OPTION;"
      echo "FLUSH PRIVILEGES;"
    fi
  else
    echo "[IMQA] MySQL password is incorrect"
  fi
fi


echo "[IMQA] MySQL configuration is done"