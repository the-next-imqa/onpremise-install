#!/usr/bin/env bash

function confirm {
  while ture
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

echo "[IMQA] Extracting packages"

rpm -i tar-1.30-9.el8.x86_64.rpm
tar -zxvf rhel8.x-imqa-packages.tar.xz

# echo "[IMQA] Installing createrpo"

# rpm -i repo/drpm-0.4.1-3.el8.x86_64.rpm
# rpm -i repo/createrepo_c-libs-0.17.7-6.el8.x86_64.rpm
# rpm -i repo/createrepo_c-0.17.7-6.el8.x86_64.rpm

# createrepo --database $HOME/repo


sudo rm -rf /etc/yum.repos.d/offline-imqa.repo

echo "[IMQA] Creating repo"
echo -e "[offline-imqa]\nname=RHEL8-IMQA-Repository\nbaseurl=file://$HOME\nenabled=1\ngpgcheck=0\nmodule_hotfixes=1" | tee /etc/yum.repos.d/offline-imqa.repo > /dev/null

echo "[IMQA] Installing Common Dependencies"
yum --disablerepo=\* --enablerepo=offline-imqa install git

echo "[IMQA] Installing nginx"
if [ $(confirm "Do you want to install nginx?") -eq 1 ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install nginx -y
  systemctl enable nginx
  systemctl start nginx
fi

echo "[IMQA] Installing haproxy"
if [ $(confirm "Do you want to install haproxy?") -eq 1 ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install haproxy -y
  systemctl enable haproxy
  systemctl start haproxy
fi

echo "[IMQA] Installing proxysql"
if [ $(confirm "Do you want to install proxysql?") -eq 1 ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install proxysql -y
  systemctl enable proxysql
  systemctl start proxysql
fi

echo "[IMQA] Installing redis"
if [ $(confirm "Do you want to install redis?") -eq 1 ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install redis -y
  systemctl enable redis
  systemctl start redis
fi

echo "[IMQA] Installing rabbitmq"
if [ $(confirm "Do you want to install rabbitmq?") -eq 1 ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install socat logrotate -y
  yum --disablerepo=\* --enablerepo=offline-imqa install erlang rabbitmq-server -y
  systemctl enable rabbitmq-server
  systemctl start rabbitmq-server
fi

echo "[IMQA] Installing JDK 11.0.3"
if [ $(confirm "Do you want to install JDK 11.0.3?") -eq 1 ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install java-11-openjdk-devel-11.0.3.7-2.el8_0 -y
fi

echo "[IMQA] Installing docker-ce"
if [ $(confirm "Do you want to install docker-ce?") -eq 1 ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  systemctl enable docker
  systemctl start docker
fi

echo "[IMQA] Installing mysql-5.7.44"
if [ $(confirm "Do you want to install mysql-5.7.44?") -eq 1 ]; then
  yum --disablerepo=\* --enablerepo=offline-imqa install mysql-community-server mysql-community-client -y
  systemctl enable mysqld
  systemctl start mysqld
fi

echo "[IMQA] Installing NVM with Node12 & Node18"
if [ $(confirm "Do you want to install NVM with Node12 & Node18?") -eq 1 ]; then
  NVM_PACKAGE_FILE=nvm-packed-12-18.tar.xz
  BASHRC=$HOME/.bashrc
  NVM_EXPORT='export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'

  if [ -f "$NVM_PACKAGE_FILE" ]; then
    echo "Installing nvm from $NVM_PACKAGE_FILE"
    tar -xJvf "$NVM_PACKAGE_FILE" -C $HOME
    sh $HOME/.nvm/install.sh
    sed -i "/$NVM_EXPORT/d" $BASHRC
    echo $NVM_EXPORT >> $BASHRC
    echo "All setup"
    echo "Reload bash profile `source ~/.bashrc`"
  else
    echo "$NVM_PACKAGE_FILE is not exist in $HOME"
    exit 1
  fi
fi