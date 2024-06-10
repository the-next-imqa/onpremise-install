#!/usr/bin/env bash

function confirm {
  while true
  do
    read -p "$1 [y/N] : " yn
    yn=${yn:-n}
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

if [ $(confirm "[IMQA] Installation Repository") -eq "1" ]; then
  echo "[IMQA] Setup Repository"
  read -p "Enter the full path of the repo folder: " REPO_FOLDER
  echo "[IMQA] Check the repo folder..."
  if [ ! -d "$REPO_FOLDER" ]; then
    mkdir -p $REPO_FOLDER
  fi

  echo "[IMQA] Extracting packages"
  rpm -i tar-1.30-9.el8.x86_64.rpm
  read -p "Enter the full path of the tar file (gz): " TAR_FILE
  if [ -f "$TAR_FILE" ]; then
    tar -zxvf $TAR_FILE -C $REPO_FOLDER
  else
    echo "$TAR_FILE is not exist"
    exit 1
  fi

  sudo rm -rf /etc/yum.repos.d/offline-imqa.repo

  echo "[IMQA] Creating repo"
  echo -e "[offline-imqa]\nname=RHEL8-IMQA-Repository\nbaseurl=file://$REPO_FOLDER/repo\nenabled=1\ngpgcheck=0\nmodule_hotfixes=1" | tee /etc/yum.repos.d/offline-imqa.repo > /dev/null
else
  echo "[IMQA] Skipping Repository Setup"
fi


if [ $(confirm "[IMQA] Installation Packages") -eq "0" ]; then
  echo "[IMQA] Skipping Installation"
  exit 0
fi

echo "[IMQA] Installing Common Dependencies"
yum --disablerepo=\* --enablerepo=offline-imqa install git

echo "[IMQA] Installing nginx"
if [ $(confirm "Do you want to install nginx?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install nginx -y
  # systemctl enable nginx
  # systemctl start nginx
fi

echo "[IMQA] Installing haproxy"
if [ $(confirm "Do you want to install haproxy?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install haproxy -y
  # systemctl enable haproxy
  # systemctl start haproxy
fi

echo "[IMQA] Installing proxysql"
if [ $(confirm "Do you want to install proxysql?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install proxysql -y
  # systemctl enable proxysql
  # systemctl start proxysql
fi

echo "[IMQA] Installing redis"
if [ $(confirm "Do you want to install redis?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install redis -y
  # systemctl enable redis
  # systemctl start redis
fi

echo "[IMQA] Installing rabbitmq"
if [ $(confirm "Do you want to install rabbitmq?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install socat logrotate -y
  yum --disablerepo=\* --enablerepo=offline-imqa install erlang rabbitmq-server -y
  # systemctl enable rabbitmq-server
  # systemctl start rabbitmq-server
fi

echo "[IMQA] Installing JDK 11.0.3"
if [ $(confirm "Do you want to install JDK 11.0.3?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install java-11-openjdk-devel-11.0.3.7-2.el8_0 -y
fi

echo "[IMQA] Installing docker-ce"
if [ $(confirm "Do you want to install docker-ce?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa --nobest install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  # systemctl enable docker
  # systemctl start docker
fi

echo "[IMQA] Installing mysql-5.7.44"
if [ $(confirm "Do you want to install mysql-5.7.44?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install mysql-community-server mysql-community-client -y
  # systemctl enable mysqld
  # systemctl start mysqld
fi

echo "[IMQA] Installing NVM with Node12 & Node18"
if [ $(confirm "Do you want to install NVM with Node12 & Node18?") -eq "1" ]; then
  NVM_PACKAGE_FILE=nvm-packed-12-18.tar.xz
  BASHRC=$HOME/.bashrc
  NVM_EXPORT='export NVM_DIR="$HOME/.nvm"\n  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
  if [ ! -d "$HOME/.nvm" ]; then
    if [ -f "$NVM_PACKAGE_FILE" ]; then
      echo "Installing nvm from $NVM_PACKAGE_FILE"
      tar -xJvf "$NVM_PACKAGE_FILE" -C $HOME
      sh $HOME/.nvm/install.sh
    else
      echo "$NVM_PACKAGE_FILE is not exist in $HOME"
      exit 1
    fi
  else
    echo "[IMQA] NVM already installed"
  fi
  sed -i "|$NVM_EXPORT|d" $BASHRC
  echo -e $NVM_EXPORT >> $BASHRC
  echo "All setup"
  echo "Reload bash profile 'source ~/.bashrc'"
fi

echo "[IMQA] Installation Done"
echo "Please restart your terminal to apply changes"