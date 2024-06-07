#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Repo 경로
REPO_DIR=
PACKAGE_NAME=

echo "[IMQA] Extracting packages"

rpm -i tar-1.30-9.el8.x86_64.rpm
tar -zxvf rhel8.x-imqa-packages.tar.xz -C $REPO_DIR

# echo "[IMQA] Installing createrpo"

# rpm -i repo/drpm-0.4.1-3.el8.x86_64.rpm
# rpm -i repo/createrepo_c-libs-0.17.7-6.el8.x86_64.rpm
# rpm -i repo/createrepo_c-0.17.7-6.el8.x86_64.rpm

# createrepo --database $HOME/repo


echo "[IMQA] Creating repo"
echo -e "[offline-imqa]\nname=RHEL8-IMQA-Repository\nbaseurl=file://$REPO_DIR\nenabled=1\ngpgcheck=0\nmodule_hotfixes=1" | tee /etc/yum.repos.d/offline-imqa.repo > /dev/null

echo "[IMQA] Installing git, nginx, haproxy, proxysql, redis"

# installing

yum --disablerepo=\* --enablerepo=offline-imqa install $PACKAGE_NAME

yum --disablerepo=\* --enablerepo=offline-imqa install git nginx haproxy proxysql redis -y

echo "[IMQA] Installing rabbitmq"
yum --disablerepo=\* --enablerepo=offline-imqa install socat logrotate -y
yum --disablerepo=\* --enablerepo=offline-imqa install erlang rabbitmq-server -y

echo "[IMQA] Installing JDK 11.0.3"
yum --disablerepo=\* --enablerepo=offline-imqa install java-11-openjdk-devel-11.0.3.7-2.el8_0 -y

echo "[IMQA] Installing docer-ce"
yum --disablerepo=\* --enablerepo=offline-imqa install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl start docker

echo "[IMQA] Installing mysql-5.7.44"
yum --disablerepo=\* --enablerepo=offline-imqa install mysql-community-server mysql-community-client -y

echo "[IMQA] Installing NVM with Node12 & Node18"

NVM_PACKAGE_FILE=nvm-packed-12-18.tar.xz
BASHRC=$HOME/.bashrc
NVM_EXPORT='export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion"'

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
