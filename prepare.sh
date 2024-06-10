#!/usr/bin/env bash

download_if_not_exists() {
  local url=$1
  local target=$2
  local description=$3

  if [ ! -e "$target" ]; then
    wget "$url" -P "$(dirname "$target")"
    echo "[IMQA] Downloaded $description"
  else
    echo "[IMQA] $description already exists. Skipping..."
  fi
}

# Download IMQA packages
IMQA_PACKAGE_FILE="rhel8.x-imqa-packages.tar.xz"
download_if_not_exists "https://cdn.oh.camp/install/$IMQA_PACKAGE_FILE" "$IMQA_PACKAGE_FILE" "IMQA package file"

# Download PM2
PM2_LOCATION="pm2"
if [ ! -d "$PM2_LOCATION" ]; then
  echo "[IMQA] Creating directory: $PWD/$PM2_LOCATION"
  mkdir -p "$PM2_LOCATION"
fi

download_if_not_exists "https://cdn.oh.camp/install/pm2-installer-node-v12.22.12.tar.gz" "$PM2_LOCATION/pm2-installer-node-v12.22.12.tar.gz" "PM2 installer for Node.js v12.22.12"
download_if_not_exists "https://cdn.oh.camp/install/pm2-installer-node-v18.20.3.tar.gz" "$PM2_LOCATION/pm2-installer-node-v18.20.3.tar.gz" "PM2 installer for Node.js v18.20.3"
download_if_not_exists "https://cdn.oh.camp/install/pm2-logrotate-2.7.0-node-v12.22.12.tar.gz" "$PM2_LOCATION/pm2-logrotate-2.7.0-node-v12.22.12.tar.gz" "PM2 logrotate v2.7.0 for Node.js v12.22.12"
download_if_not_exists "https://cdn.oh.camp/install/pm2-logrotate-2.7.0-node-v18.20.3.tar.gz" "$PM2_LOCATION/pm2-logrotate-2.7.0-node-v18.20.3.tar.gz" "PM2 logrotate v2.7.0 for Node.js v18.20.3"

echo "[IMQA] All downloads completed"