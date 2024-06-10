#!/usr/bin/env bash

# download IMQA packages
IMQA_PACKAGE_FILE=rhel8.x-imqa-packages.tar.xz
if [ ! -e "$IMQA_PACKAGE_FILE" ]; then
  wget https://cdn.oh.camp/install/rhel8.x-imqa-packages.tar.xz
else
  echo "[IMQA] IMQA package file exist. Skipping..."
fi
# download PM2
PM2_LOCATION=pm2
if [ ! -d "$PM2_LOCATION" ]; then
  echo "[IMQA] Creating directory: $PWD/$PM2_LOCATION"
  mkdir $PM2_LOCATION
fi

if [ ! -e "$PM2_LOCATION/pm2-installer-node-v12.22.12.tar.gz" ]; then
  wget https://cdn.oh.camp/install/pm2-installer-node-v12.22.12.tar.gz -P $PM2_LOCATION
else
  echo "[IMQA] PM2 installer Node12 exist. Skipping..."
fi
if [ ! -e "$PM2_LOCATION/pm2-installer-node-v18.20.3.tar.gz" ]; then
  wget https://cdn.oh.camp/install/pm2-installer-node-v18.20.3.tar.gz -P $PM2_LOCATION
else
  echo "[IMQA] PM2 installer Node18 exist. Skipping..."
fi
if [ ! -e "$PM2_LOCATION/pm2-logrotate-2.7.0-node-v12.22.12.tar.gz" ]; then
  wget https://cdn.oh.camp/install/pm2-logrotate-2.7.0-node-v12.22.12.tar.gz -P $PM2_LOCATION
else
  echo "[IMQA] PM2 logrotate 2.7.0 Node12 exist. Skipping..."
fi
if [ ! -e "$PM2_LOCATION/pm2-logrotate-2.7.0-node-v18.20.3.tar.gz" ]; then
  wget https://cdn.oh.camp/install/pm2-logrotate-2.7.0-node-v18.20.3.tar.gz -P $PM2_LOCATION
else
  echo "[IMQA] PM2 logrotate 2.7.0 Node18 exist. Skipping..."
fi
echo "[IMQA] Downloaded"